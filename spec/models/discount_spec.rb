require 'rails_helper'

RSpec.describe Discount do
  describe 'relationships' do
    it {should belong_to :merchant}
  end

  describe 'validations' do
    it {should validate_presence_of :percent}
    it {should validate_presence_of :min_qty}
  end
end

