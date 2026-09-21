---
title: What is an N+1 query?
category: performance
---

An N+1 query happens when you load a list of records (1 query), then access an
association on each one, triggering a separate query per record (N more queries).

```ruby
Post.all.each do |post|
  puts post.comments.count   # one query per post!
end
```

If there are 100 posts, this runs 1 query for the posts plus 100 more for each post's
comments, 101 queries instead of 2.

Fix it by eager loading the association up front with `includes`:

```ruby
Post.includes(:comments).each do |post|
  puts post.comments.size   # already loaded, no extra query
end
```

`includes` loads the association in a small, fixed number of extra queries (often just
one) regardless of how many posts there are. The `bullet` gem can detect N+1 queries
automatically in development and warn you in the log or browser.
