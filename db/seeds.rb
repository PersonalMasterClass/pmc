# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.delete_all
PresenterProfile.delete_all
Presenter.delete_all
Customer.delete_all
Booking.delete_all
Subject.delete_all

40.times do |f|
  word = (Faker::Hipster.words(2)* ' ').titleize
  while Subject.where(name: word).present?
    word = (Faker::Hipster.words(2)* ' ').titleize
  end
    Subject.create(name: word)
end

# Test admin
User.create!(
             user_type: :admin,
             status: :approved,
             email: "rosemary@gmail.com",
             password:              "password",
             password_confirmation: "password",
             confirmed_at: Time.now)

# Test presenter
a = User.new(
             user_type: :presenter,
             status: :approved,
             email: "presenter@gmail.com",
             password:              "password",
             password_confirmation: "password",
             confirmed_at: Time.now)
b = Presenter.create(phone_number:Faker::PhoneNumber.phone_number, 
                     first_name: 'Presenter',
                     last_name: 'Presenter', 
                     vit_number: Faker::Code.ean, 
                     abn_number: Faker::Code.ean )
b.school_info = SchoolInfo.all.sample
a.presenter = b
a.save(:validate => false)


# Some bookings



# Test customer
c = User.new(
             user_type: :customer,
             status: :approved,
             email: "customer@gmail.com",
             password:              "password",
             password_confirmation: "password",
             confirmed_at: Time.now)
d = Customer.create(phone_number:Faker::PhoneNumber.phone_number, 
                     first_name: 'Customer',
                     last_name: 'Customer', 
                     vit_number: Faker::Code.ean, 
                     abn_number: Faker::Code.ean )
d.school_info = SchoolInfo.all.sample
c.customer = d
c.save(:validate => false)


# Create test presenters
10.times do |f|
  a = User.new(
             user_type: :presenter,
             status: :pending,
             email: "example#{f+111}@gmail.com",
             password:              "password",
             password_confirmation: "password",
             confirmed_at: Time.now)
  presenter = Presenter.create(phone_number:Faker::PhoneNumber.phone_number, 
                               first_name: Faker::Name.first_name,
                               last_name: Faker::Name.last_name, 
                               vit_number: Faker::Code.ean, 
                               abn_number: Faker::Code.ean )

  presenter.school_info = SchoolInfo.all.sample


  presenter.presenter_profile = PresenterProfile.create(bio: Faker::Hipster.paragraph,
                                                        status: "approved")
  a.presenter = presenter
  3.times do  
    subject = Subject.all.sample
    a.presenter.subjects << subject if !a.presenter.subjects.include? subject
  end


  a.save(:validate => false)
end
5.times do |f|
  a = User.new(
             user_type: :customer,
             status: :pending,
             email: "example#{f+10}@gmail.com",
             password:              "password",
             password_confirmation: "password")
  customer = Customer.create(phone_number:Faker::PhoneNumber.phone_number, 
                               first_name: Faker::Name.first_name,
                               last_name: Faker::Name.last_name, 
                               vit_number: Faker::Code.ean, 
                               abn_number: Faker::Code.ean )
  a.customer = customer
  a.save(:validate => false)
end

4.times do
  Booking.create(booking_date: Time.now+rand(170).days, creator: c.customer, duration_minutes: 60)  
end


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
#   a.customer.bookings << Booking.create(shared: true, booking_date: DateTime.now)
#   a.save(:validate => false)
# end

# 5.times do |f|
#   a = User.new(
#              user_type: :customer,
#              status: :pending,
#              email: "example#{f+110}@gmail.com",
#              password:              "password",
#              password_confirmation: "password")
#   customer = Customer.create(phone_number:Faker::PhoneNumber.phone_number, 
#                                first_name: Faker::Name.first_name,
#                                last_name: Faker::Name.last_name, 
#                                vit_number: Faker::Code.ean, 
#                                abn_number: Faker::Code.ean )
#   a.customer = customer
#   a.customer.bookings << Booking.create(booking_date: DateTime.now)
#   a.save(:validate => false)
# end

