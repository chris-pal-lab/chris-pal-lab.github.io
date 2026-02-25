---
layout: page
title: Publications
permalink: /publications/
---

<div class="publications-page">
  <p class="page-intro">Global publication list for the lab. Entries are placeholders and can be replaced with final paper details.</p>

  <section class="lab-panel pub-search-panel">
    <label class="pub-search-label" for="pub-search-input">Search Publications</label>
    <input id="pub-search-input" class="pub-search-input" type="search" placeholder="Search by title, author, or venue">
    <p id="pub-search-count" class="pub-search-count"></p>
  </section>

  <div class="pub-list">
    {% for publication in site.data.publications %}
    <article class="pub-card" data-search="{{ publication.title | default: '' | downcase | escape }} {{ publication.authors | default: '' | downcase | escape }} {{ publication.venue | default: '' | downcase | escape }}">
      <div class="pub-visual">
        {% if publication.visual %}{{ publication.visual }}{% elsif publication.year %}{{ publication.year }}{% else %}Publication{% endif %}
      </div>
      <div>
        <p class="pub-index">Paper {{ forloop.index }}</p>
        <h2>{{ publication.title }}</h2>
        {% if publication.authors %}<p>{{ publication.authors }}</p>{% endif %}
        <p class="pub-venue">{{ publication.venue }}</p>
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
  </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
  var input = document.getElementById("pub-search-input");
  var count = document.getElementById("pub-search-count");
  var cards = Array.prototype.slice.call(document.querySelectorAll(".pub-list .pub-card"));

  if (!input || cards.length === 0) {
    return;
  }

  function updateResults() {
    var query = input.value.toLowerCase().trim();
    var visibleCount = 0;

    cards.forEach(function (card) {
      var haystack = (card.getAttribute("data-search") || "").toLowerCase();
      var isMatch = query === "" || haystack.indexOf(query) !== -1;
      card.style.display = isMatch ? "" : "none";
      if (isMatch) {
        visibleCount += 1;
      }
    });

    if (count) {
      if (query === "") {
        count.textContent = "Showing all " + cards.length + " publications";
      } else {
        count.textContent = "Showing " + visibleCount + " of " + cards.length + " publications";
      }
    }
  }

  input.addEventListener("input", updateResults);
  updateResults();
});
</script>
