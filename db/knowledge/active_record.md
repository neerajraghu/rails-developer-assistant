---
title: What is ActiveRecord?
category: active_record
---

ActiveRecord is Rails' Object-Relational Mapper (ORM). It lets you work with database
rows as plain Ruby objects instead of writing SQL by hand.

Each model class maps to a database table, and each instance of that class maps to one
row. For example, a `Product` model maps to a `products` table, and `Product.find(1)`
returns the row with id 1 as a `Product` object.

Common ActiveRecord methods:

```ruby
Product.all                        # every row
Product.find(1)                    # by primary key, raises if missing
Product.find_by(name: "Widget")    # first match, returns nil if missing
Product.where(active: true)        # a relation (lazy, chainable)
Product.create!(name: "Widget")    # insert and raise on validation failure
```

ActiveRecord queries are lazy: calling `.where` doesn't hit the database until you
actually use the result (e.g. iterate over it, call `.to_a`, or call `.count`).

### Difference between find and find_by

`find` looks up by primary key and raises `ActiveRecord::RecordNotFound` if there's no
match. `find_by` looks up by any attribute(s) you give it and returns `nil` instead of
raising when nothing matches.

```ruby
Product.find(1)                 # raises if id 1 doesn't exist
Product.find_by(id: 1)          # returns nil if id 1 doesn't exist
Product.find_by(name: "Widget") # first match on name, or nil
```

Use `find` when a missing record means something is genuinely wrong (a 404 is
appropriate). Use `find_by` when "not found" is a normal, expected outcome you want to
handle yourself, for example checking whether a user with a given email already
exists.
