---
layout: page
title: People
permalink: /people/
description: Faculty, postdocs, students, and collaborators in the Chris Pal Research Group.
---

<div class="people-page">
  <p class="page-intro">Members of the research group. All content below is placeholder text.</p>

  <nav class="people-tabs" aria-label="People Sections">
    {% for section in site.data.people.sections %}
    <a class="people-tab-chip" href="#{{ section.title | slugify }}">{{ section.title }}</a>
    {% endfor %}
  </nav>

  <section class="lab-panel people-search-panel">
    <label class="people-search-label" for="people-search-input">Search People</label>
    <input id="people-search-input" class="people-search-input" type="search" placeholder="Search by name, role, focus, or email">
    <p id="people-search-count" class="people-search-count"></p>
  </section>

  {% for section in site.data.people.sections %}
  <section id="{{ section.title | slugify }}" class="lab-panel people-section" data-people-section>
    <h2>{{ section.title }}</h2>
    <div class="people-grid">
      {% for person in section.members %}
      {% assign search_email = person.email | default: '' | downcase | replace: '.', ' [dot] ' | replace: '@', ' [at] ' %}
      <article class="person-card" data-search="{{ person.name | default: '' | downcase | escape }} {{ person.role | default: '' | downcase | escape }} {{ person.focus | default: '' | downcase | escape }} {{ search_email | escape }}">
        {% if person.headshot %}
        <img class="person-headshot" src="{{ person.headshot | relative_url }}" alt="Headshot of {{ person.name }}">
        {% endif %}
        <h3>{{ person.name }}</h3>
        <p class="person-role">{{ person.role }}</p>
        {% if person.email %}
        {% assign email_parts = person.email | split: '@' %}
        {% assign email_user = email_parts[0] | replace: '.', ' [dot] ' %}
        {% assign email_domain = email_parts[1] | replace: '.', ' [dot] ' %}
        <p class="person-email">{{ email_user }} [at] {{ email_domain }}</p>
        {% endif %}
        <p><strong>Working on:</strong> {{ person.focus }}</p>
        <div class="person-links">
          {% if person.links.github %}<a class="link-chip" href="{{ person.links.github }}">GitHub</a>{% endif %}
          {% if person.links.website %}<a class="link-chip" href="{{ person.links.website }}">Website</a>{% endif %}
          {% if person.links.scholar %}<a class="link-chip" href="{{ person.links.scholar }}">Scholar</a>{% endif %}
          {% if person.links.twitter %}<a class="link-chip" href="{{ person.links.twitter }}">X/Twitter</a>{% endif %}
          {% if person.links.bluesky %}<a class="link-chip" href="{{ person.links.bluesky }}">Bluesky</a>{% endif %}
          {% if person.links.linkedin %}<a class="link-chip" href="{{ person.links.linkedin }}">LinkedIn</a>{% endif %}
        </div>
      </article>
      {% endfor %}
    </div>
  </section>
  {% endfor %}
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
  var input = document.getElementById("people-search-input");
  var count = document.getElementById("people-search-count");
  var cards = Array.prototype.slice.call(document.querySelectorAll(".people-grid .person-card"));
  var sections = Array.prototype.slice.call(document.querySelectorAll("[data-people-section]"));

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

    sections.forEach(function (section) {
      var hasVisibleCard = Array.prototype.some.call(section.querySelectorAll(".person-card"), function (card) {
        return card.style.display !== "none";
      });
      section.style.display = hasVisibleCard ? "" : "none";
    });

    if (count) {
      if (query === "") {
        count.textContent = "Showing all " + cards.length + " people";
      } else {
        count.textContent = "Showing " + visibleCount + " of " + cards.length + " people";
      }
    }
  }

  input.addEventListener("input", updateResults);
  updateResults();
});
</script>
