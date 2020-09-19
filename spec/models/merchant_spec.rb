require 'rails_helper'

RSpec.describe Merchant do
  describe 'relationships' do
    it {should have_many :items}
    it {should have_many(:order_items).through(:items)}
    it {should have_many :users}
    it {should have_many :discounts}
  end

  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :address}
    it {should validate_presence_of :city}
    it {should validate_presence_of :state}
    it {should validate_presence_of :zip}
  end

  describe 'instance Methods' do
    before :each do
      @monster_shop = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @bagel_shop = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @reptile_shop = Merchant.create!(name: 'Sals Salamanders', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @ogre = @monster_shop.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant =  @monster_shop.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @bagel_shop.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )

      @user_1 = User.create!(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan_1@example.com', password: 'securepassword')
      @user_2 = User.create!(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'IA', zip: 80218, email: 'megan_2@example.com', password: 'securepassword')

      @order_1 = @user_1.orders.create!
      @order_2 = @user_2.orders.create!(status: 1)
      @order_3 = @user_2.orders.create!(status: 1)

      @order_item_1 = @order_1.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2)
      @order_item_2 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 3)
      @order_item_3 = @order_2.order_items.create!(item: @giant, price: @hippo.price, quantity: 2)
      @order_item_4 = @order_2.order_items.create!(item: @ogre, price: @hippo.price, quantity: 2)

      @monster_shop.discounts.create!(percent: 10, min_qty: 2)
      @monster_shop.discounts.create!(percent: 10, min_qty: 10)
      @monster_shop.discounts.create!(percent: 15, min_qty: 8)
      @monster_shop.discounts.create!(percent: 20, min_qty: 20)
    end

    it '.item_count' do
      expect(@monster_shop.item_count).to eq(2)
      expect(@bagel_shop.item_count).to eq(1)
      expect(@reptile_shop.item_count).to eq(0)
    end

    it '.average_item_price' do
      expect(@monster_shop.average_item_price.round(2)).to eq(35.13)
      expect(@bagel_shop.average_item_price.round(2)).to eq(50.00)
    end

    it '.distinct_cities' do
      expect(@monster_shop.distinct_cities).to eq(['Denver, CO', 'Denver, IA'])
    end

    it '.pending_orders' do
      expect(@monster_shop.pending_orders).to eq([@order_1])
    end

    it '.order_items_by_order' do
      expect(@monster_shop.order_items_by_order(@order_1.id)).to eq([@order_item_1])
    end

    it 'lowest_min_qty_discount' do
      expect(@monster_shop.lowest_min_qty_discount).to eq(2)
      expect(@bagel_shop.lowest_min_qty_discount).to eq(nil)
    end

    it 'offers_discount?' do 
      expect(@monster_shop.offers_discount?).to eq(true)
      expect(@bagel_shop.offers_discount?).to eq(false)
    end

    it 'discount_percent_for(qty)' do 
      expect(@monster_shop.discount_percent_for(2)).to eq(10)
      expect(@monster_shop.discount_percent_for(10)).to eq(15)
    end
  end
end
