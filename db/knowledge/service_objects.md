---
title: How to write a Rails service object
category: service_objects
---

A service object is a plain Ruby class that holds one piece of business logic that
doesn't naturally belong on a single model, things like "place an order," "send an
invitation," or "import a CSV." It exists to keep controllers thin and models focused
on data, not multi-step processes.

A common convention: one public method, usually `call` or `perform`, instantiated with
the data it needs.

```ruby
class PlaceOrder
  def initialize(cart:, user:)
    @cart = cart
    @user = user
  end

  def call
    order = Order.create!(user: @user, total: @cart.total)
    @cart.line_items.each { |item| order.line_items << item }
    @cart.destroy
    order
  end
end

# usage
PlaceOrder.new(cart: current_cart, user: current_user).call
```

Keep it doing one thing. If a service object starts branching into several unrelated
responsibilities, that's usually a sign it should be split into more than one class.
