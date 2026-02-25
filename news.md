---
layout: page
title: News
permalink: /news/
description: Archive of announcements and updates from the Chris Pal Lab.
---

<div class="publications-page">
  <p class="page-intro">Archive of announcements and updates from the group.</p>

  <div class="news-timeline">
    {% assign news_items = site.posts | where_exp: "post", "post.categories contains 'news'" %}
    {% for item in news_items %}
    <article class="timeline-item">
      <div class="timeline-dot" aria-hidden="true"></div>
      <div class="timeline-content">
        <p class="news-date">{{ item.date | date: "%B %-d, %Y" }}</p>
        <h2>{{ item.title }}</h2>
        <p>{{ item.summary | default: item.excerpt | strip_html }}</p>
        <a href="{{ item.url | relative_url }}">Read more</a>
      </div>
    </article>
    {% endfor %}
  </div>
</div>
