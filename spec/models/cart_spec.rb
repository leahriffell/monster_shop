require 'rails_helper'

RSpec.describe Cart do
  describe 'Instance Methods' do
    before :each do
      @monster_shop = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @pet_shop = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @ogre = @monster_shop.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @monster_shop.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 2 )
      @hippo = @pet_shop.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )

      @monster_shop.discounts.create!(percent: 0.1, min_qty: 2)

      @cart = Cart.new({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
    end

    it '.contents' do
      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
    end

    it '.add_item()' do
      @cart.add_item(@hippo.id.to_s)

      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2,
        @hippo.id.to_s => 1
        })
    end

    it '.count' do
      expect(@cart.count).to eq(3)
    end

    it '.items' do
      expect(@cart.items).to eq([@ogre, @giant])
    end

    it '.grand_total' do
      expect(@cart.grand_total).to eq(110)
    end

    it '.count_of()' do
      expect(@cart.count_of(@ogre.id)).to eq(1)
      expect(@cart.count_of(@giant.id)).to eq(2)
    end

    it '.subtotal_of()' do
      expect(@cart.subtotal_of(@ogre.id)).to eq(20)
      expect(@cart.subtotal_of(@giant.id)).to eq(100)
    end

    it '.limit_reached?()' do
      expect(@cart.limit_reached?(@ogre.id)).to eq(false)
      expect(@cart.limit_reached?(@giant.id)).to eq(true)
    end

    it '.less_item()' do
      @cart.less_item(@giant.id.to_s)

      expect(@cart.count_of(@giant.id)).to eq(1)
    end

    it '.has_discount?(item)' do
      @cart.add_item(@hippo.id.to_s)

      expect(@cart.has_discount(@giant)).to eq(true)
      expect(@cart.has_discount(@ogre)).to eq(false)
      expect(@cart.has_discount(@hippo)).to eq(false)
    end

    it '.discount_percent_for(item)' do 
      expect(@cart.discount_percent_for(@ogre)).to eq(nil)
      expect(@cart.discount_percent_for(@giant)).to eq(0.1)
    end

    it '.discount_price_for(item)' do 
      expect(@cart.discount_price_for(@giant)).to eq(45)
    end

    it '.subtotal_with_discount(item, discount_percent)' do
      discount_percent = @cart.discount_percent_for(@giant)
      discounted_price = @giant.price * (1 - @cart.discount_percent_for(@giant))
      qty = @cart.count_of(@giant.id)
      total = discounted_price * qty

      expect(@cart.subtotal_with_discount(@giant, discount_percent)).to eq(total)
    end

    it 'any_discounts?' do
      @cart_2 = Cart.new({})

      expect(@cart.any_discounts?).to eq(true)
      expect(@cart_2.any_discounts?).to eq(false)
    end
  end
end
