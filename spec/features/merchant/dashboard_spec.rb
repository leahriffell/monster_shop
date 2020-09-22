require 'rails_helper'

RSpec.describe 'Merchant Dashboard' do
  describe 'As an employee of a merchant' do
    before :each do
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)

      @m_user = FactoryBot.create(:user, email: 'merchant@merchant.com', password: 'password', role: 1)
      @merchant_1.users << @m_user

      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )

      @order_1 = @m_user.orders.create!(status: "pending")
      @order_2 = @m_user.orders.create!(status: "pending")
      @order_3 = @m_user.orders.create!(status: "pending")
      
      @order_item_1 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: false)
      @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: true)
      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
      @order_item_4 = @order_3.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)

      5.times do 
        create(:discount, merchant: @merchant_1)
      end

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
    end

    it 'I can see my merchants information on the merchant dashboard' do
      visit '/merchant'

      expect(page).to have_link(@merchant_1.name)
      expect(page).to have_content(@merchant_1.address)
      expect(page).to have_content("#{@merchant_1.city} #{@merchant_1.state} #{@merchant_1.zip}")
    end

    it 'I do not have a link to edit the merchant information' do
      visit '/merchant'

      within(".merchant-info") do
        expect(page).to_not have_link('Edit')
      end
    end

    it 'I see a list of pending orders containing my items' do
      visit '/merchant'

      within '.orders' do
        expect(page).to_not have_css("#order-#{@order_1.id}")

        within "#order-#{@order_2.id}" do
          expect(page).to have_link(@order_2.id)
          expect(page).to have_content("Potential Revenue: #{@order_2.merchant_subtotal(@merchant_1.id)}")
          expect(page).to have_content("Quantity of Items: #{@order_2.merchant_quantity(@merchant_1.id)}")
          expect(page).to have_content("Created: #{@order_2.created_at}")
        end

        within "#order-#{@order_3.id}" do
          expect(page).to have_link(@order_3.id)
          expect(page).to have_content("Potential Revenue: #{@order_3.merchant_subtotal(@merchant_1.id)}")
          expect(page).to have_content("Quantity of Items: #{@order_3.merchant_quantity(@merchant_1.id)}")
          expect(page).to have_content("Created: #{@order_3.created_at}")
        end
      end
    end

    it 'I can link to an order show page' do
      visit '/merchant'

      click_link @order_2.id

      expect(current_path).to eq("/merchant/orders/#{@order_2.id}")
    end

    it 'I can see any discounts my merchant offers' do
      visit '/merchant'

      @merchant_1.discounts.each do |discount|
        within("#discount-#{discount.id}") do
          expect(page).to have_content("Discount percent: #{(discount.percent*100).round(0)}%")
          expect(page).to have_content("Minimum quantity: #{discount.min_qty}")
        end
      end
    end

    it "I can link to form for adding new discount" do 
      visit '/merchant'

      click_link "Add discount"
      expect(current_path).to eq("/merchant/discounts/new")
    end

    it "I can link to form for editing a discount" do 
      visit '/merchant'

      @merchant_1.discounts.each do |discount|
        within("#discount-#{discount.id}") do
          click_link "Edit"
          expect(current_path).to eq("/merchant/discounts/#{discount.id}/edit")
          visit '/merchant'
        end
      end
  end

    it "I can delete a discount" do
      visit '/merchant'
      
      within("#discount-#{@merchant_1.discounts.first.id}") do
        click_link "Delete"
      end

      expect(current_path).to eq("/merchant")

      expect(@merchant_1.discounts.size).to eq(4)
      expect(page).to_not have_css("#discount-#{discount.id}")
    end
  end
end