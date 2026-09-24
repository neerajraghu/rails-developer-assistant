---
title: has_many, has_one, and belongs_to
category: associations
---

Associations describe relationships between models.

- `belongs_to` goes on the model whose table holds the foreign key. A `Comment`
  belongs_to a `Post` because the `comments` table has a `post_id` column.
- `has_many` goes on the other side. A `Post` has_many `:comments`.
- `has_one` is like `has_many`, but for a relationship where there is only ever one
  related record, for example a `User` has_one `:profile`.

```ruby
class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
end

class Comment < ApplicationRecord
  belongs_to :post
end
```

### Difference between has_many and has_one

`has_many` returns a collection (an ActiveRecord relation you can iterate, filter, and
count). `has_one` returns a single record or nil. Use `has_one` only when the
relationship is genuinely one-to-one; if a user could ever have more than one profile,
that should be `has_many` instead.

### What is dependent: :destroy?

`dependent: :destroy` tells Rails what to do to the associated records when the parent
is destroyed. With `dependent: :destroy` on `has_many :comments`, deleting a `Post`
also loads and destroys each of its comments (running their own callbacks and
validations). Without it, deleting the post would leave orphaned comment rows pointing
at a post_id that no longer exists, unless the database itself enforces a foreign key
constraint.
