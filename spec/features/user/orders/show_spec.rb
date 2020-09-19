require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Order Show Page' do
  describe 'As a Registered User' do
    before :each do
      @monster_shop = Merchant.create!(name: 'Megans Monsters', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @pet_shop = Merchant.create!(name: 'Brians Pets', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @reptile_shop = Merchant.create!(name: 'Sals Salamanders', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @ogre = @monster_shop.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @monster_shop.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @pet_shop.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )

      @user = User.create!(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan_1@example.com', password: 'securepassword')

      @order_1 = @user.orders.create!(status: "packaged")
      @order_2 = @user.orders.create!(status: "pending")
      @order_3 = @user.orders.create!(status: "pending")

      @order_item_1 = @order_1.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: true)
      @order_item_2 = @order_2.order_items.create!(item: @giant, price: @hippo.price, quantity: 2, fulfilled: true)
      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
      @order_item_4 = @order_3.order_items.create!(item: @ogre, price: @ogre.price, quantity: 50, fulfilled: false)

      @pet_shop.discounts.create!(percent: 0.1, min_qty: 50)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it 'I can link from my orders to an order show page' do
      visit '/profile/orders'

      click_link @order_1.id

      expect(current_path).to eq("/profile/orders/#{@order_1.id}")
    end

    it 'I see order information on the show page' do
      visit "/profile/orders/#{@order_2.id}"

      expect(page).to have_content(@order_2.id)
      expect(page).to have_content("Created On: #{@order_2.created_at}")
      expect(page).to have_content("Updated On: #{@order_2.updated_at}")
      expect(page).to have_content("Status: #{@order_2.status}")
      expect(page).to have_content("#{@order_2.count_of_items} items")
      expect(page).to have_content("Total: #{number_to_currency(@order_2.grand_total)}")

      within "#order-item-#{@order_item_2.id}" do
        expect(page).to have_link(@order_item_2.item.name)
        expect(page).to have_content(@order_item_2.item.description)
        expect(page).to have_content(@order_item_2.quantity)
        expect(page).to have_content(@order_item_2.price)
        expect(page).to have_content(@order_item_2.subtotal)
      end

      within "#order-item-#{@order_item_3.id}" do
        expect(page).to have_link(@order_item_3.item.name)
        expect(page).to have_content(@order_item_3.item.description)
        expect(page).to have_content(@order_item_3.quantity)
        expect(page).to have_content(@order_item_3.price)
        expect(page).to have_content(@order_item_3.subtotal)
      end
    end

    it 'I can see info for order w/ discounts' do
      @cart = Cart.new({
        @ogre.id.to_s => 1,
        @hippo.id.to_s => 50
      })

      allow_any_instance_of(ApplicationController).to receive(:cart).and_return(@cart)
      visit '/cart'
      click_button 'Check Out'

      order = @user.orders.last 
      discount_order_item = order.order_items.where(item_id: @hippo.id).first

      visit "/profile/orders/#{order.id}"

      expect(page).to have_content("Total: #{number_to_currency(@cart.grand_total)}")

      within("#order-item-#{discount_order_item.id}") do
        expect(page).to have_content("Price: #{number_to_currency(@hippo.price * (1 - @cart.discount_percent_for(@hippo)))}")
      end
    end

    it 'I see a link to cancel an order, only on a pending order show page' do
      visit "/profile/orders/#{@order_1.id}"

      expect(page).to_not have_button('Cancel Order')

      visit "/profile/orders/#{@order_2.id}"

      expect(page).to have_button('Cancel Order')
    end

    it 'I can cancel an order to return its contents to the items inventory' do
      visit "/profile/orders/#{@order_2.id}"

      click_button 'Cancel Order'

      expect(current_path).to eq("/profile/orders/#{@order_2.id}")
      expect(page).to have_content("Status: cancelled")

      @giant.reload
      @ogre.reload
      @order_item_2.reload
      @order_item_3.reload

      expect(@order_item_2.fulfilled).to eq(false)
      expect(@order_item_3.fulfilled).to eq(false)
      expect(@giant.inventory).to eq(5)
      expect(@ogre.inventory).to eq(7)
    end
  end
end
