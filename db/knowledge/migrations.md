---
title: How Rails migrations work
category: migrations
---

A migration is a versioned, ordered change to your database schema, written in Ruby
instead of raw SQL.

```ruby
class AddAgeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :age, :integer
  end
end
```

Each migration file is timestamped, and Rails tracks which ones have already run in a
`schema_migrations` table. Running `rails db:migrate` applies every migration newer
than the last one that ran, in order.

Most migrations only need a `change` method, Rails can figure out how to reverse
simple operations like `add_column` or `create_table` automatically (so `rails db:rollback`
works without you writing an `up`/`down` pair). For changes Rails can't automatically
reverse (like a data migration, or `change_column` in some cases), you write explicit
`up` and `down` methods instead.

`rails db:migrate` also updates `db/schema.rb`, a single file describing the database's
current full structure, which is what a fresh environment loads from instead of
replaying every migration from scratch.
