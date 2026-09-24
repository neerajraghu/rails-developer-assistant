---
title: Writing a Rails request spec
category: testing
---

A request spec (RSpec) tests a controller action the way a real HTTP request would:
it sends a request and checks the response, without rendering a full browser.

```ruby
RSpec.describe "Posts", type: :request do
  it "creates a post and redirects to it" do
    post posts_path, params: { post: { title: "Hello", body: "World" } }

    expect(response).to redirect_to(Post.last)
  end

  it "rejects a post with no title" do
    post posts_path, params: { post: { title: "", body: "World" } }

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
```

Request specs sit between fast, narrow model/service specs and slow, full-browser
system specs. Use them to check the whole request-response cycle (routing, params
handling, status codes, redirects) without the overhead of driving a real browser.
