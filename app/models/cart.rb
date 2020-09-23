class Cart
  attr_reader :contents

  def initialize(contents)
    @contents = contents || {}
    @contents.default = 0
  end

  def add_item(item_id)
    @contents[item_id] += 1
  end

  def less_item(item_id)
    @contents[item_id] -= 1
  end

  def count
    @contents.values.sum
  end

  def items
    @contents.map do |item_id, _|
      Item.find(item_id)
    end
  end

  def grand_total
    grand_total = 0.0
    @contents.each do |item_id, quantity|
      if has_discount(Item.find(item_id))
        grand_total += discount_price_for(Item.find(item_id)) * quantity
      else
        grand_total += Item.find(item_id).price * quantity
      end
    end
    grand_total
  end

  def count_of(item_id)
    @contents[item_id.to_s]
  end

  def subtotal_of(item_id)
    @contents[item_id.to_s] * Item.find(item_id).price
  end

  def limit_reached?(item_id)
    count_of(item_id) == Item.find(item_id).inventory
  end

  def has_discount(item)
    if item.merchant.offers_discount?
      count_of(item.id) >= item.merchant.lowest_min_qty_discount
    else 
      false 
    end
  end

  def discount_percent_for(item)
    if has_discount(item)
      item.merchant.discount_percent_for(count_of(item.id))
    else 
      nil
    end
  end

  def discount_price_for(item)
    item.price * (1 - self.discount_percent_for(item))
  end

  def subtotal_with_discount(item, discount_percent) 
    @contents[item.id.to_s] * (Item.find(item.id).price * (1 - discount_percent))
  end
end
