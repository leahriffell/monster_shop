FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip_code }
    email { Faker::Internet.unique.email }
    role { Faker::Number.within(range: 0..2) }
    password { Faker::Superhero.power }
  end
end