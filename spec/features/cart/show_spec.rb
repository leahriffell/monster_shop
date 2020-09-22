require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Cart Show Page' do
  describe 'As a Visitor' do
    before :each do
      @monster_shop = Merchant.create!(name: 'Megans Monsters', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @pet_shop = Merchant.create!(name: 'Brians Pets', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @ogre = @monster_shop.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @monster_shop.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )

      @hippo = @pet_shop.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
    end

    describe 'I can see my cart' do
      it "I can visit a cart show page to see items in my cart" do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        expect(page).to have_content("Total: #{number_to_currency((@ogre.price * 1) + (@hippo.price * 2))}")

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to have_content("Price: #{number_to_currency(@ogre.price)}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: #{number_to_currency(@ogre.price * 1)}")
          expect(page).to have_content("Sold by: #{@monster_shop.name}")
          expect(page).to have_css("img[src*='#{@ogre.image}']")
          expect(page).to have_link(@monster_shop.name)
        end

        within "#item-#{@hippo.id}" do
          expect(page).to have_link(@hippo.name)
          expect(page).to have_content("Price: #{number_to_currency(@hippo.price)}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal: #{number_to_currency(@hippo.price * 2)}")
          expect(page).to have_content("Sold by: #{@pet_shop.name}")
          expect(page).to have_css("img[src*='#{@hippo.image}']")
          expect(page).to have_link(@pet_shop.name)
        end
      end

      it "I can visit an empty cart page" do
        visit '/cart'

        expect(page).to have_content('Your Cart is Empty!')
        expect(page).to_not have_button('Empty Cart')
      end
    end

    describe 'I can manipulate my cart' do
      it 'I can empty my cart' do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        click_button 'Empty Cart'

        expect(current_path).to eq('/cart')
        expect(page).to have_content('Your Cart is Empty!')
        expect(page).to have_content('Cart: 0')
        expect(page).to_not have_button('Empty Cart')
      end

      it 'I can remove one item from my cart' do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('Remove')
        end

        expect(current_path).to eq('/cart')
        expect(page).to_not have_content("#{@hippo.name}")
        expect(page).to have_content('Cart: 1')
        expect(page).to have_content("#{@ogre.name}")
      end

      it 'I can add quantity to an item in my cart' do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('More of This!')
        end

        expect(current_path).to eq('/cart')
        within "#item-#{@hippo.id}" do
          expect(page).to have_content('Quantity: 3')
        end
      end

      it 'I can not add more quantity than the items inventory' do
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          expect(page).to_not have_button('More of This!')
        end

        visit "/items/#{@hippo.id}"

        click_button 'Add to Cart'

        expect(page).to have_content("You have all the item's inventory in your cart already!")
      end

      it 'I can reduce the quantity of an item in my cart' do
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('Less of This!')
        end

        expect(current_path).to eq('/cart')
        within "#item-#{@hippo.id}" do
          expect(page).to have_content('Quantity: 2')
        end
      end

      it 'if I reduce the quantity to zero, the item is removed from my cart' do
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('Less of This!')
        end

        expect(current_path).to eq('/cart')
        expect(page).to_not have_content("#{@hippo.name}")
        expect(page).to have_content("Cart: 0")
      end
    end

    describe 'I can view discounts in cart' do
      before :each do 
        @monster_shop.discounts.create!(percent: 0.1, min_qty: 2)
        @monster_shop.discounts.create!(percent: 0.1, min_qty: 10)
        @monster_shop.discounts.create!(percent: 0.15, min_qty: 8)
        @monster_shop.discounts.create!(percent: 0.2, min_qty: 20)
        @pet_shop.discounts.create!(percent: 0.2, min_qty: 50)
      end

      it 'I can view any existing discounts on items reflected in subtotals and total'do
        @cart = Cart.new({
          @ogre.id.to_s => 1,
          @giant.id.to_s => 10,
          })

        allow_any_instance_of(ApplicationController).to receive(:cart).and_return(@cart)

        visit '/cart'

        within("#item-#{@ogre.id}") do 
          expect(page).to have_content("Price: #{number_to_currency(@ogre.price)}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@cart.subtotal_of(@ogre.id))}")
        end

        within("#item-#{@giant.id}") do 
          expect(page).to have_content("Discounted price: #{number_to_currency(@giant.price * (1 - @cart.discount_percent_for(@giant)))}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@cart.count_of(@giant.id) * @cart.discount_price_for(@giant))}")
        end

        expect(page).to have_content("Total: #{number_to_currency((@ogre.price * 1) + (42.5 * 10))}")
      end

      it "I can increase item while in cart to qualify for a discount" do 
        @cart = Cart.new({
          @hippo.id.to_s => 49,
          })

        allow_any_instance_of(ApplicationController).to receive(:cart).and_return(@cart)

        visit '/cart'

        within("#item-#{@hippo.id}") do 
          expect(page).to have_content("Price: #{number_to_currency(@hippo.price)}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@cart.count_of(@hippo.id) * @hippo.price)}")
        end

        expect(page).to have_content("Total: #{number_to_currency(@cart.count_of(@hippo.id) * @hippo.price)}")

        within("#item-#{@hippo.id}") do 
          click_button('More of This!')
          expect(page).to have_content("Discounted price: #{number_to_currency(@hippo.price * (1 - @cart.discount_percent_for(@hippo)))}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@cart.count_of(@hippo.id) * @cart.discount_price_for(@hippo))}")
        end

        expect(page).to have_content("Total: #{number_to_currency(@cart.count_of(@hippo.id) * @cart.discount_price_for(@hippo))}")
      end

      it "I can decrease item while in cart to disqualify for a discount" do 
        @cart = Cart.new({
          @hippo.id.to_s => 50,
          })

        allow_any_instance_of(ApplicationController).to receive(:cart).and_return(@cart)

        visit '/cart'
      end
    end
  end
end
