---
layout: page
title: News
permalink: /news/
description: Archive of announcements and updates from the Chris Pal Lab.
---

<div class="publications-page">
  <p class="page-intro">Archive of announcements and updates from the group.</p>

  <div class="news-timeline">
    {% assign news_items = site.data.news | sort: 'date' | reverse %}
    {% for item in news_items %}
    <article class="timeline-item">
      <div class="timeline-dot" aria-hidden="true"></div>
      <div class="timeline-content">
        <p class="news-date">{{ item.date | date: "%B %-d, %Y" }}</p>
        <h2>{{ item.title }}</h2>
        <p>{{ item.summary }}</p>
        {% if item.link %}
        <a href="{{ item.link }}">Read more</a>
        {% endif %}
      </div>
    </article>
    {% endfor %}
  </div>
</div>
