# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.delete_all
Presenter.delete_all
Customer.delete_all
User.create!(
             user_type: :admin,
             status: :approved,
             email: "rosemary@gmail.com",
             password:              "password",
             password_confirmation: "password")

# 5.times do |f|
#   a = User.new(
#              user_type: :presenter,
#              status: :pending,
#              email: "example#{f+1}@gmail.com",
#              password:              "password",
#              password_confirmation: "password")
#   presenter = Presenter.create(phone_number:Faker::PhoneNumber.phone_number, 
#                                first_name: Faker::Name.first_name,
#                                last_name: Faker::Name.last_name, 
#                                vit_number: Faker::Code.ean, 
#                                abn_number: Faker::Code.ean )
#   a.presenter = presenter
#   a.save(:validate => false)
# end
# 5.times do |f|
#   a = User.new(
#              user_type: :customer,
#              status: :pending,
#              email: "example#{f+10}@gmail.com",
#              password:              "password",
#              password_confirmation: "password")
#   customer = Customer.create(phone_number:Faker::PhoneNumber.phone_number, 
#                                first_name: Faker::Name.first_name,
#                                last_name: Faker::Name.last_name, 
#                                vit_number: Faker::Code.ean, 
#                                abn_number: Faker::Code.ean )
#   a.customer = customer
#   a.save(:validate => false)
# end

