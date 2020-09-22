class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  def subtotal
    quantity * price
  end

  def fulfill
    update(fulfilled: true)
    item.update(inventory: item.inventory - quantity)
  end

  def fulfillable?
    item.inventory >= quantity
  end

  def was_discounted? 
    price < item_regular_price
  end

  def item_regular_price
    Item.find(item_id).price
  end
end
