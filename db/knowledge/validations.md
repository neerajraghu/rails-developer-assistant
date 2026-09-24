---
title: Rails model validations
category: validations
---

Validations are rules a model checks before saving to the database. They run when you
call `save`, `create`, or `update` (not their bang variants only, plain `save` runs
them too, it just returns `false` on failure instead of raising).

```ruby
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :age, numericality: { greater_than_or_equal_to: 18 }
end
```

If a validation fails, `user.save` returns `false` and `user.errors` is populated with
the failure messages. `user.save!` raises `ActiveRecord::RecordInvalid` instead.

Validations protect data integrity at the application layer. They are not a substitute
for database-level constraints (like `NOT NULL` or a unique index) if you need
guarantees that hold even for code paths that bypass ActiveRecord.
