---
layout: page
title: Publications
permalink: /publications/
description: Publications from the Chris Pal Lab, searchable and organized by year.
---

<div class="publications-page">
  <p class="page-intro">Global publication list for the lab. Entries are placeholders and can be replaced with final paper details.</p>

  {% assign publications_sorted = site.data.publications | sort: "year" | reverse %}

  <section class="lab-panel pub-search-panel">
    <label class="pub-search-label" for="pub-search-input">Search Publications</label>
    <input id="pub-search-input" class="pub-search-input" type="search" placeholder="Search by title, author, or venue">
    <div class="pub-filter-row">
      <span class="pub-filter-label">Filters</span>
      <div id="pub-filter-chips" class="pub-filter-chips">
        <button type="button" class="filter-chip is-active" data-filter-kind="all">All</button>
        {% assign previous_year_chip = "" %}
        {% for publication in publications_sorted %}
          {% assign chip_year = publication.year | default: "Unknown" | append: "" %}
          {% unless chip_year == previous_year_chip %}
            <button type="button" class="filter-chip" data-filter-kind="year" data-filter-value="{{ chip_year }}">{{ chip_year }}</button>
            {% assign previous_year_chip = chip_year %}
          {% endunless %}
        {% endfor %}
      </div>
    </div>
    <p id="pub-search-count" class="pub-search-count"></p>
  </section>

  <div class="pub-year-groups">
    {% assign current_year = "" %}
    {% for publication in publications_sorted %}
      {% assign publication_year = publication.year | default: "Unknown" | append: "" %}
      {% if publication_year != current_year %}
        {% unless forloop.first %}</div></details>{% endunless %}
        <details class="pub-year-group" open data-year-group="{{ publication_year }}">
          <summary>
            <span>{{ publication_year }}</span>
            <span class="pub-year-meta"></span>
          </summary>
          <div class="pub-list">
        {% assign current_year = publication_year %}
      {% endif %}
      <article class="pub-card" data-year="{{ publication_year }}" data-search="{{ publication.title | default: '' | downcase | escape }} {{ publication.authors | default: '' | downcase | escape }} {{ publication.venue | default: '' | downcase | escape }} {{ publication.tags | join: ' ' | downcase | escape }}">
        <div class="pub-visual">
          {% if publication.visual %}{{ publication.visual }}{% elsif publication.year %}{{ publication.year }}{% else %}Publication{% endif %}
        </div>
        <div>
          <h2>{{ publication.title }}</h2>
          {% if publication.authors %}<p>{{ publication.authors }}</p>{% endif %}
          <p class="pub-venue">{{ publication.venue }}</p>
          {% if publication.tags %}
          <div class="pub-tags">
            {% for tag in publication.tags %}
            <span class="tag-chip">{{ tag }}</span>
            {% endfor %}
          </div>
          {% endif %}
          {% if publication.venues %}
          <p class="pub-extra-venues">
            Also appeared in:
            {% assign sep = "" %}
            {% for v in publication.venues %}
              {% if v != publication.venue %}
                {{ sep }}{{ v }}
                {% assign sep = "; " %}
              {% endif %}
            {% endfor %}
          </p>
          {% endif %}
          {% if publication.summary %}<p>{{ publication.summary }}</p>{% endif %}
          {% if publication.arxiv or publication.project_page or publication.twitter or publication.doi %}
          <div class="pub-links">
            {% if publication.arxiv %}<a class="link-chip" href="{{ publication.arxiv }}">arXiv</a>{% endif %}
            {% if publication.project_page %}<a class="link-chip" href="{{ publication.project_page }}">Project Page</a>{% endif %}
            {% if publication.doi %}<a class="link-chip" href="https://doi.org/{{ publication.doi }}">DOI</a>{% endif %}
            {% if publication.twitter %}<a class="link-chip" href="{{ publication.twitter }}">X/Twitter</a>{% endif %}
          </div>
          {% endif %}
        </div>
      </article>
    {% endfor %}
    {% unless publications_sorted == empty %}</div></details>{% endunless %}
  </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
  var input = document.getElementById("pub-search-input");
  var count = document.getElementById("pub-search-count");
  var chips = Array.prototype.slice.call(document.querySelectorAll("#pub-filter-chips .filter-chip"));
  var cards = Array.prototype.slice.call(document.querySelectorAll(".pub-year-groups .pub-card"));
  var groups = Array.prototype.slice.call(document.querySelectorAll(".pub-year-group"));
  var activeFilter = { kind: "all", value: "" };

  if (!input || cards.length === 0) {
    return;
  }

  function matchesFilter(card) {
    if (activeFilter.kind === "all") return true;
    if (activeFilter.kind === "year") return card.getAttribute("data-year") === activeFilter.value;
    return true;
  }

  function updateResults() {
    var query = input.value.toLowerCase().trim();
    var visibleCount = 0;

    cards.forEach(function (card) {
      var haystack = (card.getAttribute("data-search") || "").toLowerCase();
      var isMatch = (query === "" || haystack.indexOf(query) !== -1) && matchesFilter(card);
      card.style.display = isMatch ? "" : "none";
      if (isMatch) {
        visibleCount += 1;
      }
    });

    groups.forEach(function (group) {
      var groupCards = group.querySelectorAll(".pub-card");
      var groupVisibleCount = Array.prototype.filter.call(groupCards, function (card) {
        return card.style.display !== "none";
      }).length;
      group.style.display = groupVisibleCount > 0 ? "" : "none";
      var meta = group.querySelector(".pub-year-meta");
      if (meta) {
        meta.textContent = groupVisibleCount + " publication" + (groupVisibleCount === 1 ? "" : "s");
      }
    });

    if (count) {
      if (query === "" && activeFilter.kind === "all") {
        count.textContent = "Showing all " + cards.length + " publications";
      } else {
        count.textContent = "Showing " + visibleCount + " of " + cards.length + " publications";
      }
    }
  }

  chips.forEach(function (chip) {
    chip.addEventListener("click", function () {
      chips.forEach(function (c) { c.classList.remove("is-active"); });
      chip.classList.add("is-active");
      activeFilter = {
        kind: chip.getAttribute("data-filter-kind") || "all",
        value: chip.getAttribute("data-filter-value") || ""
      };
      updateResults();
    });
  });

  input.addEventListener("input", updateResults);
  updateResults();
});
</script>
