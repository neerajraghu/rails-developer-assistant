---
title: How Rails routing works
category: routing
---

`config/routes.rb` maps an incoming HTTP verb + path to a controller action.

```ruby
resources :posts
```

This one line generates seven routes: index, new, create, show, edit, update, and
destroy, all pointing at `PostsController`. You can list every route Rails knows about
with `rails routes`.

If you only need some of them, narrow it down:

```ruby
resources :posts, only: %i[index show create]
```

Nested resources express that one resource belongs to another:

```ruby
resources :posts do
  resources :comments, only: %i[create]
end
```

This generates a path like `/posts/1/comments`, and inside `CommentsController#create`
you'd look up the parent with `Post.find(params[:post_id])`.

Routing is matched top to bottom, so a more specific route needs to be declared before
a more general one that could also match the same path.
