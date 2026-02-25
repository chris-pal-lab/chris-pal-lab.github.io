---
layout: default
title: Home
permalink: /
description: Homepage for the Chris Pal Lab, featuring research areas, people, and recent news.
---

<div class="lab-home">
  <section class="lab-hero">
    <img class="hero-mark" src="{{ '/assets/images/lab-mark.svg' | relative_url }}" alt="" aria-hidden="true">
    <p class="eyebrow">Academic Research Group</p>
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
      <li>
        <strong>Computer Vision and Pattern Recognition</strong>
        Methods for robust visual understanding, perception, and representation learning across varied data regimes.
      </li>
      <li>
        <strong>Computational Photography</strong>
        AI-driven approaches for image formation, enhancement, restoration, and controllable visual generation.
      </li>
      <li>
        <strong>Natural Language Processing</strong>
        Large-scale language modeling, generation, and reasoning for real-world human-AI applications.
      </li>
      <li>
        <strong>Statistical Machine Learning and HCI Applications</strong>
        Data-efficient probabilistic methods and interactive AI systems designed to support people and organizations.
      </li>
    </ul>
    <p>Across these areas, the group emphasizes scalable generative modeling techniques, principled learning methods, and deployment-oriented research that bridges foundational ML with high-impact applications.</p>
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
    {% assign news_items = site.data.news | sort: "date" | reverse %}
    <div class="news-grid">
      {% for item in news_items limit: 3 %}
      <article class="news-card">
        <p class="news-date">{{ item.date | date: "%B %-d, %Y" }}</p>
        <h3>{{ item.title }}</h3>
        <p>{{ item.summary }}</p>
        {% if item.link %}
        <a href="{{ item.link }}">Read more</a>
        {% endif %}
      </article>
      {% endfor %}
    </div>
    <p><a href="{{ '/news/' | relative_url }}">View full news archive</a></p>
  </section>
</div>
