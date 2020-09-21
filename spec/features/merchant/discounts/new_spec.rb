require 'rails_helper'

RSpec.describe 'Create new merchant discount page' do
  describe 'As an employee of a merchant' do
    before :each do
      merchant_1 = create(:merchant)
      merchant_admin = FactoryBot.create(:user, role: 1, merchant: merchant_1)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant_admin)
    end

    it "I can create a new discount for my merchant" do 
      visit "/merchant/discounts/new"

      fill_in :discount_percent, with: 50
      fill_in :discount_min_qty, with: 10
      click_button "Create Discount"

      new_discount = Discount.last

      expect(current_path).to eq("/merchant")

      within("#discount-#{new_discount.id}") do
        expect(page).to have_content("Discount percent: #{new_discount.percent.round(0)}%")
        expect(page).to have_content("Minimum quantity: #{new_discount.min_qty}")
      end
    end
  end
end
