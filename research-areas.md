---
layout: page
title: Research Areas
permalink: /research-areas/
description: Research area overview for the Chris Pal Lab, with links to people and publications.
---

<div class="publications-page">
  <p class="page-intro">Explore the lab's research areas, with related people and publications.</p>

  <nav class="people-tabs" aria-label="Research Area Sections">
    {% for area in site.data.research_areas %}
    <a class="people-tab-chip" href="#{{ area.title | slugify }}">{{ area.title }}</a>
    {% endfor %}
  </nav>

  {% assign publications_sorted = site.data.publications | sort: "year" | reverse %}

  {% for area in site.data.research_areas %}
  <section id="{{ area.title | slugify }}" class="lab-panel area-section">
    <h2>{{ area.title }}</h2>
    <p>{{ area.description }}</p>

    <div class="areas-grid">
      <article class="area-card">
        <h3>People</h3>
        <ul class="area-list">
          {% assign area_people_count = 0 %}
          {% for section in site.data.people.sections %}
            {% for person in section.members %}
              {% assign focus_text = person.focus | default: "" | downcase %}
              {% assign person_match = false %}
              {% for keyword in area.keywords %}
                {% if focus_text contains keyword %}
                  {% assign person_match = true %}
                  {% break %}
                {% endif %}
              {% endfor %}
              {% if person_match %}
              {% assign area_people_count = area_people_count | plus: 1 %}
              <li><strong>{{ person.name }}</strong> <span class="area-meta">({{ person.role }})</span></li>
              {% endif %}
            {% endfor %}
          {% endfor %}
          {% if area_people_count == 0 %}
          <li>No people matches found yet.</li>
          {% endif %}
        </ul>
      </article>

      <article class="area-card">
        <h3>Publications</h3>
        <ul class="area-list">
          {% assign area_pub_count = 0 %}
          {% for publication in publications_sorted %}
            {% assign pub_match = false %}
            {% if publication.tags %}
              {% for tag in publication.tags %}
                {% if area.publication_tags contains tag %}
                  {% assign pub_match = true %}
                  {% break %}
                {% endif %}
              {% endfor %}
            {% endif %}
            {% if pub_match %}
              {% assign area_pub_count = area_pub_count | plus: 1 %}
              {% if area_pub_count <= 8 %}
              <li>
                {{ publication.title }}
                {% if publication.year %}<span class="area-meta">({{ publication.year }})</span>{% endif %}
              </li>
              {% endif %}
            {% endif %}
          {% endfor %}
          {% if area_pub_count == 0 %}
          <li>No publication matches found yet.</li>
          {% elsif area_pub_count > 8 %}
          <li class="area-meta">Showing 8 of {{ area_pub_count }} matches. See Publications for full list.</li>
          {% endif %}
        </ul>
      </article>
    </div>

    <p class="area-links">
      <a href="{{ '/people/' | relative_url }}">Browse all people</a> ·
      <a href="{{ '/publications/' | relative_url }}">Browse all publications</a>
    </p>
  </section>
  {% endfor %}
</div>
