FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::Marketing.buzzwords }
    image { Faker::Fillmurray.image }
    price { Faker::Commerce.price }
    inventory { Faker::Number.number(digits: 4) }
    association :merchant
  end
end