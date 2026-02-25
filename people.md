---
layout: page
title: People
permalink: /people/
---

<div class="people-page">
  <p class="page-intro">Members of the research group. All content below is placeholder text.</p>

  {% for section in site.data.people.sections %}
  <section class="lab-panel people-section">
    <h2>{{ section.title }}</h2>
    <div class="people-grid">
      {% for person in section.members %}
      <article class="person-card">
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
