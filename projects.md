---
layout: page
title: Major Projects
permalink: /projects/
published: false
---

<div class="projects-page">
  <p class="page-intro">Major ongoing and planned efforts across the lab. Entries are placeholders.</p>

  <div class="project-grid">
    {% for project in site.data.projects %}
    <article class="project-card">
      <h2>{{ project.name }}</h2>
      <p>{{ project.overview }}</p>
      <p class="project-meta"><span class="status-pill">{{ project.status }}</span> Team: {{ project.team }}</p>
      {% if project.project_page or project.code %}
      <div class="project-links">
        {% if project.project_page %}<a class="link-chip" href="{{ project.project_page }}">Project Page</a>{% endif %}
        {% if project.code %}<a class="link-chip" href="{{ project.code }}">Code</a>{% endif %}
      </div>
      {% endif %}
    </article>
    {% endfor %}
  </div>
</div>
