#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "optparse"
require "yaml"
require "fileutils"
require "date"

LATEX_ACCENTS = {
  "'" => {
    "a" => "á", "e" => "é", "i" => "í", "o" => "ó", "u" => "ú", "y" => "ý",
    "A" => "Á", "E" => "É", "I" => "Í", "O" => "Ó", "U" => "Ú", "Y" => "Ý"
  },
  "`" => {
    "a" => "à", "e" => "è", "i" => "ì", "o" => "ò", "u" => "ù",
    "A" => "À", "E" => "È", "I" => "Ì", "O" => "Ò", "U" => "Ù"
  },
  "^" => {
    "a" => "â", "e" => "ê", "i" => "î", "o" => "ô", "u" => "û",
    "A" => "Â", "E" => "Ê", "I" => "Î", "O" => "Ô", "U" => "Û"
  },
  '"' => {
    "a" => "ä", "e" => "ë", "i" => "ï", "o" => "ö", "u" => "ü", "y" => "ÿ",
    "A" => "Ä", "E" => "Ë", "I" => "Ï", "O" => "Ö", "U" => "Ü", "Y" => "Ÿ"
  },
  "~" => {
    "a" => "ã", "n" => "ñ", "o" => "õ",
    "A" => "Ã", "N" => "Ñ", "O" => "Õ"
  },
  "c" => {
    "c" => "ç", "C" => "Ç"
  },
  "v" => {
    "c" => "č", "s" => "š", "z" => "ž", "r" => "ř", "e" => "ě", "n" => "ň",
    "C" => "Č", "S" => "Š", "Z" => "Ž", "R" => "Ř", "E" => "Ě", "N" => "Ň"
  }
}.freeze

LATEX_SYMBOLS = {
  "\\&" => "&",
  "\\%" => "%",
  "\\_" => "_",
  "\\#" => "#",
  "\\$" => "$",
  "\\{" => "{",
  "\\}" => "}",
  "~" => " "
}.freeze

def present?(value)
  !value.nil? && !value.to_s.strip.empty?
end

def latex_to_unicode(value)
  text = value.to_s.dup

  text.gsub!(/\\([`'"^"~cv])\{?([A-Za-z])\}?/) do
    accent = Regexp.last_match(1)
    letter = Regexp.last_match(2)
    LATEX_ACCENTS.fetch(accent, {}).fetch(letter, Regexp.last_match(0))
  end

  LATEX_SYMBOLS.each do |latex, unicode|
    text.gsub!(latex, unicode)
  end

  text.gsub(/[{}]/, "")
end

def split_top_level(input, delimiter = ",")
  parts = []
  current = +""
  brace_depth = 0
  in_quotes = false
  escape = false

  input.each_char do |char|
    if escape
      current << char
      escape = false
      next
    end

    if char == "\\"
      current << char
      escape = true
      next
    end

    if char == '"'
      in_quotes = !in_quotes
      current << char
      next
    end

    unless in_quotes
      brace_depth += 1 if char == "{"
      brace_depth -= 1 if char == "}" && brace_depth.positive?
    end

    if char == delimiter && brace_depth.zero? && !in_quotes
      parts << current.strip
      current = +""
    else
      current << char
    end
  end

  parts << current.strip unless current.strip.empty?
  parts
end

def delimiter_balance_delta(line, open_char, close_char)
  in_quotes = false
  escape = false
  delta = 0

  line.each_char do |char|
    if escape
      escape = false
      next
    end
    if char == "\\"
      escape = true
      next
    end
    if char == '"'
      in_quotes = !in_quotes
      next
    end
    next if in_quotes

    delta += 1 if char == open_char
    delta -= 1 if char == close_char
  end

  delta
end

def collect_raw_entries(text, source_path)
  lines = text.lines
  entries = []
  idx = 0

  while idx < lines.length
    line = lines[idx]
    match = line.match(/^\s*@([A-Za-z]+)\s*([\{\(])/)
    unless match
      idx += 1
      next
    end

    entry_type = match[1].downcase
    open_char = match[2]
    close_char = open_char == "{" ? "}" : ")"

    buffer = +""
    depth = 0

    while idx < lines.length
      current = lines[idx]
      buffer << current
      depth += delimiter_balance_delta(current, open_char, close_char)
      idx += 1
      break if depth <= 0
    end

    entries << {
      type: entry_type,
      raw: buffer,
      complete: depth <= 0,
      source_file: File.basename(source_path)
    }
  end

  entries
end

def clean_value(raw)
  value = raw.to_s.strip
  value = value.sub(/,\s*\z/, "").strip

  loop do
    stripped = value.strip
    if stripped.start_with?("{") && stripped.end_with?("}")
      value = stripped[1..-2].strip
    elsif stripped.start_with?('"') && stripped.end_with?('"')
      value = stripped[1..-2].strip
    else
      break
    end
  end

  value = latex_to_unicode(value)
  value.gsub(/\s+/, " ").strip
end

def parse_entry(entry)
  raw = entry[:raw].strip
  opening_idx = raw.index("{") || raw.index("(")
  return nil unless opening_idx

  body = raw[(opening_idx + 1)..]
  body = body.sub(/[}\)]\s*\z/m, "") if entry[:complete]

  parts = split_top_level(body)
  return nil if parts.empty?

  bibtex_key = parts.shift.to_s.strip
  fields = {}

  parts.each do |chunk|
    name, value = chunk.split("=", 2)
    next unless value

    field_name = name.to_s.strip.downcase
    fields[field_name] = clean_value(value)
  end

  {
    "entry_type" => entry[:type],
    "bibtex_key" => bibtex_key,
    "source_file" => entry[:source_file],
    "title" => clean_value(fields["title"]),
    "authors" => clean_value(fields["author"]),
    "year" => clean_value(fields["year"]),
    "venue" => clean_value(fields["journal"] || fields["booktitle"]),
    "doi" => clean_value(fields["doi"]),
    "url" => clean_value(fields["url"]),
    "eprint" => clean_value(fields["eprint"]),
    "archiveprefix" => clean_value(fields["archiveprefix"])
  }
end

def extract_arxiv_id(candidate)
  return nil unless present?(candidate)

  text = candidate.to_s
  patterns = [
    /arxiv\.org\/abs\/([a-z\-\.]+\/\d{7}|\d{4}\.\d{4,5}(?:v\d+)?)/i,
    /arxiv:\s*([a-z\-\.]+\/\d{7}|\d{4}\.\d{4,5}(?:v\d+)?)/i
  ]

  patterns.each do |pattern|
    match = text.match(pattern)
    return match[1] if match
  end

  nil
end

def arxiv_link(record)
  if present?(record["eprint"]) && record["archiveprefix"].to_s.downcase == "arxiv"
    return "https://arxiv.org/abs/#{record['eprint']}"
  end

  %w[url venue].each do |field|
    arxiv_id = extract_arxiv_id(record[field])
    return "https://arxiv.org/abs/#{arxiv_id}" if arxiv_id
  end

  nil
end

def normalize_doi(doi)
  return nil unless present?(doi)

  doi.to_s.strip.downcase
     .sub(%r{^https?://(dx\.)?doi\.org/}, "")
end

def canonical_title(title)
  title.to_s.downcase.gsub(/[^a-z0-9]+/, " ").strip
end

def merge_unique_values(left, right)
  merged = []
  seen = {}

  (Array(left) + Array(right)).each do |item|
    next unless present?(item)

    value = item.to_s.strip
    key = value.downcase
    next if seen[key]

    seen[key] = true
    merged << value
  end

  merged
end

def select_primary_venue(venues)
  list = merge_unique_values(venues, [])
  return nil if list.empty?

  non_arxiv = list.reject { |v| v.downcase.include?("arxiv") }
  pool = non_arxiv.empty? ? list : non_arxiv
  pool.max_by { |v| v.length }
end

def smart_capitalize_token(token, index_in_name)
  return token if token.include?("{") || token.include?("\\")
  return token if token =~ /\A[[:upper:]]{2,}\z/
  return "others" if token.downcase == "others"

  suffix = token[/\*+\z/] || ""
  base = token.sub(/\*+\z/, "")

  if index_in_name.positive? && %w[de da del der van von di la le du dos das den ter].include?(base.downcase)
    return base.downcase + suffix
  end

  normalized = base.split(/([-'])/).map do |part|
    if part == "-" || part == "'"
      part
    elsif part =~ /\A[a-zA-Z]\.\z/
      part[0].upcase + "."
    elsif part.empty?
      part
    else
      part[0].upcase + part[1..].downcase
    end
  end.join

  normalized + suffix
end

def normalize_name_phrase(phrase)
  words = phrase.to_s.strip.split(/\s+/)
  words.each_with_index.map { |word, idx| smart_capitalize_token(word, idx) }.join(" ")
end

def normalize_author_name(author)
  token = author.to_s.strip
  return token unless present?(token)

  if token.include?(",")
    parts = token.split(",", 2).map(&:strip)
    family = normalize_name_phrase(parts[0])
    given = normalize_name_phrase(parts[1].to_s)
    given.empty? ? family : "#{family}, #{given}"
  else
    normalize_name_phrase(token)
  end
end

def normalize_author_list(authors)
  return nil unless present?(authors)

  authors.to_s
         .split(/\s+and\s+/i)
         .map { |author| normalize_author_name(author) }
         .join(" and ")
end

def chris_pal_author?(author_token)
  text = author_token.to_s.downcase.gsub(/[^a-z,\s]/, " ").gsub(/\s+/, " ").strip
  return false if text.empty?

  return true if text.match?(/\bchris(?:topher)?\b/) && text.match?(/\bpal\b/)
  return true if text.match?(/\bpal,\s*chris(?:topher)?\b/)

  false
end

def include_chris_pal?(authors)
  return false unless present?(authors)

  authors.to_s.split(/\s+and\s+/i).any? { |token| chris_pal_author?(token) }
end

def primary_dedupe_key(record)
  doi = normalize_doi(record["doi"])
  return "doi:#{doi}" if present?(doi)

  bibkey = Array(record["bibtex_keys"]).first.to_s.strip.downcase
  return "bibkey:#{bibkey}" if present?(bibkey)

  arxiv_id = extract_arxiv_id(record["arxiv"])
  return "arxiv:#{arxiv_id.downcase}" if present?(arxiv_id)

  "fallback:#{record['bibtex_key']}:#{record['source_file']}"
end

def title_dedupe_key(record)
  normalized_title = canonical_title(record["title"])
  return "title:#{normalized_title}" if present?(normalized_title)

  primary_dedupe_key(record)
end

def merge_record_fields(old_value, new_value)
  return old_value if !present?(new_value)
  return new_value if !present?(old_value)

  new_value.length > old_value.length ? new_value : old_value
end

def merge_records(existing, incoming)
  merged = existing.dup

  %w[title authors year doi url arxiv].each do |field|
    merged[field] = merge_record_fields(merged[field], incoming[field])
  end

  merged["venues"] = merge_unique_values(existing["venues"], incoming["venues"])
  merged["venue"] = select_primary_venue(merged["venues"])
  merged["source_files"] = (Array(existing["source_files"]) + Array(incoming["source_files"])).uniq
  merged["bibtex_keys"] = (Array(existing["bibtex_keys"]) + Array(incoming["bibtex_keys"])).uniq
  merged["entry_types"] = (Array(existing["entry_types"]) + Array(incoming["entry_types"])).uniq

  merged
end

def year_sort_value(value)
  value.to_s[/\d{4}/].to_i
end

def normalize_tags(tags)
  Array(tags).map { |tag| tag.to_s.strip.downcase.gsub(/\s+/, "-") }.reject(&:empty?).uniq
end

def load_existing_tag_index(path)
  index = { by_title: {}, by_doi: {} }
  return index unless File.exist?(path)

  parsed = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true)
  return index unless parsed.is_a?(Array)

  parsed.each do |row|
    next unless row.is_a?(Hash)

    tags = normalize_tags(row["tags"])
    next if tags.empty?

    title_key = canonical_title(row["title"])
    index[:by_title][title_key] = tags if present?(title_key)

    doi_key = normalize_doi(row["doi"])
    index[:by_doi][doi_key] = tags if present?(doi_key)
  end

  index
rescue Psych::Exception => e
  warn "Warning: Failed to read existing tags from #{path}: #{e.message}"
  index
end

options = {
  input_dir: "bibtex",
  csv_out: "bibtex/publications_master.csv",
  yaml_out: "_data/publications.yml"
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby scripts/build_publications_from_bibtex.rb [options]"
  opts.on("--input DIR", "Input directory containing .bib files (default: bibtex)") { |v| options[:input_dir] = v }
  opts.on("--csv-out PATH", "Output CSV path (default: bibtex/publications_master.csv)") { |v| options[:csv_out] = v }
  opts.on("--yaml-out PATH", "Output YAML path (default: _data/publications.yml)") { |v| options[:yaml_out] = v }
end.parse!

bib_files = Dir.glob(File.join(options[:input_dir], "*.bib")).sort
if bib_files.empty?
  warn "No .bib files found in #{options[:input_dir]}"
  exit 1
end

raw_entries = []
bib_files.each do |path|
  content = File.read(path)
  raw_entries.concat(collect_raw_entries(content, path))
end

incomplete_entries = raw_entries.reject { |e| e[:complete] }
incomplete_entries.each do |entry|
  warn "Warning: Incomplete BibTeX entry detected in #{entry[:source_file]} (entry may be truncated)."
end

records = raw_entries.map do |entry|
  parsed = parse_entry(entry)
  next nil unless parsed
  next nil unless present?(parsed["title"])

  parsed["arxiv"] = arxiv_link(parsed)
  parsed["doi"] = normalize_doi(parsed["doi"])
  parsed["authors"] = normalize_author_list(parsed["authors"])
  parsed["venues"] = present?(parsed["venue"]) ? [parsed["venue"]] : []
  parsed["venue"] = select_primary_venue(parsed["venues"])
  parsed["source_files"] = [parsed.delete("source_file")]
  parsed["bibtex_keys"] = [parsed.delete("bibtex_key")]
  parsed["entry_types"] = [parsed.delete("entry_type")]
  parsed
end.compact

deduped_primary = {}
records.each do |record|
  key = primary_dedupe_key(record)
  if deduped_primary.key?(key)
    deduped_primary[key] = merge_records(deduped_primary[key], record)
  else
    deduped_primary[key] = record
  end
end

deduped_by_title = {}
deduped_primary.values.each do |record|
  key = title_dedupe_key(record)
  if deduped_by_title.key?(key)
    deduped_by_title[key] = merge_records(deduped_by_title[key], record)
  else
    deduped_by_title[key] = record
  end
end

pal_records = deduped_by_title.values.select { |record| include_chris_pal?(record["authors"]) }

final_records = pal_records.sort_by do |record|
  [-year_sort_value(record["year"]), record["title"].to_s.downcase]
end

FileUtils.mkdir_p(File.dirname(options[:csv_out]))
CSV.open(options[:csv_out], "w") do |csv|
  csv << ["title", "authors", "year", "venue", "venues", "type", "doi", "arxiv", "url", "bibtex_keys", "source_files"]
  final_records.each do |record|
    csv << [
      record["title"],
      record["authors"],
      record["year"],
      record["venue"],
      Array(record["venues"]).join(";"),
      Array(record["entry_types"]).join(";"),
      record["doi"],
      record["arxiv"],
      record["url"],
      Array(record["bibtex_keys"]).join(";"),
      Array(record["source_files"]).join(";")
    ]
  end
end

tag_index = load_existing_tag_index(options[:yaml_out])

yaml_records = final_records.map do |record|
  row = {}
  row["title"] = record["title"]
  row["authors"] = record["authors"] if present?(record["authors"])
  row["year"] = year_sort_value(record["year"]) if present?(record["year"])
  row["venue"] = record["venue"] if present?(record["venue"])
  if Array(record["venues"]).length > 1
    row["venues"] = merge_unique_values(record["venues"], [])
  end
  row["arxiv"] = record["arxiv"] if present?(record["arxiv"])
  row["doi"] = record["doi"] if present?(record["doi"])

  if present?(record["url"]) && !record["url"].to_s.downcase.include?("arxiv.org")
    row["project_page"] = record["url"]
  end

  existing_tags = nil
  doi_key = normalize_doi(record["doi"])
  existing_tags = tag_index[:by_doi][doi_key] if present?(doi_key)
  existing_tags ||= tag_index[:by_title][canonical_title(record["title"])]
  existing_tags = normalize_tags(existing_tags)
  row["tags"] = existing_tags unless existing_tags.empty?

  row
end

FileUtils.mkdir_p(File.dirname(options[:yaml_out]))
File.write(options[:yaml_out], YAML.dump(yaml_records))

puts "Processed #{bib_files.length} bib files"
puts "Parsed #{records.length} entries (#{incomplete_entries.length} incomplete source entries encountered)"
puts "Deduped to #{deduped_primary.values.length} unique publications by DOI/bibkey/arXiv"
puts "Deduped to #{deduped_by_title.values.length} unique publications after title merge"
puts "Wrote #{final_records.length} unique publications with Chris/Christopher Pal in authors:"
puts "- CSV:  #{options[:csv_out]}"
puts "- YAML: #{options[:yaml_out]}"
