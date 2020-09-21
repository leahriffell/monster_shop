FactoryBot.define do
  factory :merchant do
    name { Faker::TvShows::RuPaul.queen }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip_code }
  end
end