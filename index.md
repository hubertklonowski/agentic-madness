---
layout: libdoc/page
title: "Welcome to Agentic Madness"
description: "Exploring the world of AI agents and autonomous systems"
---

<div class="latest-post">
  {% assign latest_post = site.posts.first %}
  {% if latest_post %}
    <article class="post-preview">
    <div class="post-meta-inline u-fs-xs u-c-primary-alt u-p-lg u-pt-none u-pb-sm u-mb-sm u-bb-thin-dashed-alt" u-p-sm="sm">
        <span class="latest-indicator u-fs-xs u-c-primary u-mr-sm">📝 Latest post</span>
        <time datetime="{{ latest_post.date | date_to_xmlschema }}">{{ latest_post.date | date: "%b %d, %Y" }}</time>
        {% if latest_post.categories.size > 0 %}
          <span class="u-mx-xs">•</span>
          {% for category in latest_post.categories %}
            <a href="{{ '/assets/libdoc/search.html' | relative_url }}?query={{ category | url_encode }}" class="post-category">{{ category }}</a>{% unless forloop.last %}, {% endunless %}
          {% endfor %}
        {% endif %}
        {% if latest_post.tags.size > 0 %}
          <span class="u-mx-xs">•</span>
          {% for tag in latest_post.tags %}
            <a href="{{ '/assets/libdoc/search.html' | relative_url }}?query={{ tag | url_encode }}" class="tag">#{{ tag }}</a>{% unless forloop.last %} {% endunless %}
          {% endfor %}
        {% endif %}
          </div>
          
          <div class="post-content u-p-lg u-pt-xs" u-p-sm="sm">
        {{ latest_post.content }}
          </div>
    </article>
  {% else %}
    <p class="u-ta-center u-c-primary-alt u-py-xxl">No posts available yet.</p>
  {% endif %}
</div>

{% if site.posts.size > 1 %}
<section class="recent-posts u-mt-xxl">
  <h3 class="u-bb-thin-dashed-alt u-pb-sm u-mb-md">Recent Posts</h3>
  <div class="post-list">
    {% for post in site.posts limit:5 offset:1 %}
      <article class="post-list-item u-mb-md u-pb-md u-bb-thin-dashed-alt">
        <h4 class="u-mt-none u-mb-xs">
          <a href="{{ post.url | relative_url }}" class="u-c-primary">{{ post.title }}</a>
        </h4>
        <div class="post-meta u-fs-xs u-c-primary-alt u-mb-sm">
          <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%b %d, %Y" }}</time>
          {% if post.categories.size > 0 %}
            <span class="u-mx-xs">•</span>
            {% for category in post.categories %}
              <span class="post-category">{{ category }}</span>{% unless forloop.last %}, {% endunless %}
            {% endfor %}
          {% endif %}
        </div>
        <p class="u-fs-sm u-lh-base u-m-none">{{ post.content | strip_html | truncatewords: 25 }}</p>
      </article>
    {% endfor %}
  </div>
</section>
{% endif %}

<!-- Comments Section for Latest Post -->
<section class="comments-section u-bt-thin-dashed-alt u-p-lg u-mt-lg" u-p-sm="sm">
  <h2 class="u-fs-lg u-mb-md">Comments</h2>
  {% include giscus.html %}
</section>

<script>
// Highlight the latest post in sidebar on home page
document.addEventListener('DOMContentLoaded', function() {
  if (window.location.pathname === '{{ site.baseurl }}/' || window.location.pathname === '{{ site.baseurl }}/index.html') {
    // Find the first post link in sidebar and highlight it
    const latestPostUrl = '{{ site.posts.first.url | relative_url }}';
    const sidebarLinks = document.querySelectorAll('#libdoc-sidebar-menu a[href]');
    
    sidebarLinks.forEach(link => {
      if (link.getAttribute('href') === latestPostUrl) {
        link.parentElement.classList.add('libdoc-sidebar-current-item');
        link.classList.add('u-br-large-solid');
        link.classList.remove('m-ff-lead');
      }
    });
  }
});
</script>