class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :order_items, through: :items
  has_many :orders, through: :order_items
  has_many :users
  has_many :discounts

  validates_presence_of :name,
                        :address,
                        :city,
                        :state,
                        :zip

  def item_count
    items.count
  end

  def average_item_price
    items.average(:price)
  end

  def distinct_cities
    orders.joins('JOIN users ON orders.user_id = users.id')
          .order('city_state')
          .distinct
          .pluck("CONCAT_WS(', ', users.city, users.state) AS city_state")
  end

  def pending_orders
    orders.where(status: 'pending')
  end

  def order_items_by_order(order_id)
    order_items.where(order_id: order_id)
  end

  def lowest_min_qty_discount
    discounts.order(:min_qty).limit(1).pluck(:min_qty).first
  end

  def offers_discount?
    discounts.count > 0 
  end

  def discount_percent_for(qty)
    discounts.where("min_qty <= #{qty}").order(percent: :desc).first.percent
  end
end
