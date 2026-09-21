---
title: Rails controllers
category: controllers
---

A controller handles an incoming request, loads or changes data, and picks what to
render or where to redirect. Rails convention keeps controllers thin: the real logic
belongs in models or service objects, the controller just wires the request to it.

```ruby
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
```

`params.require(:post).permit(:title, :body)` is Rails' protection against mass
assignment: only the listed fields can be set from user input, even if the submitted
form includes extra fields like `admin: true`.

A thin controller action usually has three parts: find or build a record, act on it
(save, update, destroy), and respond (render a view, redirect, or return an error
status). If an action grows past a few lines of actual logic, that logic likely belongs
in a model method or a service object instead.
