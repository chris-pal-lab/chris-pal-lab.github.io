---
layout: default
title: Home
permalink: /
description: Homepage for the Chris Pal Lab, featuring research areas, people, and recent news.
---

<div class="lab-home">
  <section class="lab-hero">
    <img class="hero-mark" src="{{ '/assets/images/lab-mark.svg' | relative_url }}" alt="" aria-hidden="true">
    <h1>Chris Pal Lab</h1>
    <p>We build machine learning systems that connect strong theoretical foundations with practical impact across language, vision, and multimodal AI.</p>
    <div class="hero-links">
      <a class="button-link" href="{{ '/people/' | relative_url }}">Meet the Team</a>
      <a class="button-link" href="{{ '/publications/' | relative_url }}">Browse Publications</a>
      <a class="button-link" href="{{ '/news/' | relative_url }}">Group News</a>
    </div>
  </section>

  <section class="lab-panel">
    <h2>Research Focus</h2>
    <ul class="focus-list">
      {% for area in site.data.research_areas %}
      <li>
        <a class="focus-link" href="{{ '/research-areas/' | relative_url }}#{{ area.title | slugify }}">
          <strong>{{ area.title }}</strong>
          {{ area.description }}
        </a>
      </li>
      {% endfor %}
    </ul>
    <p>Click any area to jump to its dedicated section with people and publication links.</p>
  </section>

  <section class="lab-panel">
    <h2>Principal Investigator</h2>
    <div class="pi-card">
      <img class="pi-headshot" src="{{ '/assets/images/headshots/chris_pal.jpeg' | relative_url }}" alt="Headshot of Christopher Pal">
      <div class="pi-bio">
        <p><strong>Christopher Pal</strong> is a Canada CIFAR AI Chair, full professor at Polytechnique Montréal, and adjunct professor in the Department of Computer Science and Operations Research (DIRO) at Université de Montréal. He is also a Distinguished Scientist at ServiceNow Research.</p>
        <p>Pal has been involved in AI and machine learning research for over twenty-five years and has published extensively on large-scale language modelling methods and generative modelling techniques. He holds a PhD in computer science from the University of Waterloo.</p>
      </div>
    </div>
  </section>

  <section class="lab-panel">
    <h2>News from the Group</h2>
    {% assign news_items = site.posts | where_exp: "post", "post.categories contains 'news'" %}
    <div class="news-grid">
      {% for item in news_items limit: 3 %}
      <article class="news-card">
        <p class="news-date">{{ item.date | date: "%B %-d, %Y" }}</p>
        <h3>{{ item.title }}</h3>
        <p>{{ item.summary | default: item.excerpt | strip_html }}</p>
        <a href="{{ item.url | relative_url }}">Read more</a>
      </article>
      {% endfor %}
    </div>
    <p><a href="{{ '/news/' | relative_url }}">View full news archive</a></p>
  </section>
</div>
