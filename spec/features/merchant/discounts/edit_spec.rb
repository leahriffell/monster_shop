require 'rails_helper'

RSpec.describe 'Merchant Discount Edit Page' do
  describe 'As an employee of a merchant' do
    before :each do
      @merchant = create(:merchant)

      @m_user = FactoryBot.create(:user, email: 'merchant@merchant.com', password: 'password', role: 1)
      @merchant.users << @m_user

      @discount = create(:discount, merchant: @merchant)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
    end

    it "I can see existing discount information pre-populated" do 
      visit "/merchant/discounts/#{@discount.id}/edit"

      expect(find_field(:discount_percent).value).to eq("#{@discount.percent}")
      expect(find_field(:discount_min_qty).value).to eq("#{@discount.min_qty}")
    end
    
    it "I can edit existing info" do 
      visit "/merchant/discounts/#{@discount.id}/edit"

      fill_in :discount_percent, with: 0.07
      fill_in :discount_min_qty, with: 7
      click_button "Update Discount"

      visit '/merchant'

      within("#discount-#{@discount.id}") do
        expect(page).to have_content("Discount percent: 7%")
        expect(page).to have_content("Minimum quantity: 7")
      end
    end
  end
end