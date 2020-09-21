# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

OrderItem.destroy_all
Item.destroy_all
Order.destroy_all
User.destroy_all
Discount.destroy_all
Merchant.destroy_all

# merchants
monster_shop = Merchant.create(name: 'Megans Monsters', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
pet_shop = Merchant.create(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)

# users
@default_user = FactoryBot.create(:user, email: 'user@user.com', password: 'password', role: 0)
@merchant_admin = FactoryBot.create(:user, email: 'merchant@merchant.com', password: 'password', role: 1)
monster_shop.users << @merchant_admin
@admin = FactoryBot.create(:user, email: 'admin@admin.com', password: 'password', role: 2)

# items
10.times do 
  FactoryBot.create(:item, merchant: monster_shop)
end

10.times do 
  FactoryBot.create(:item, merchant: pet_shop)
end

# discounts
5.times do 
  FactoryBot.create(:discount, merchant: monster_shop)
end

5.times do 
  FactoryBot.create(:discount, merchant: pet_shop)
end