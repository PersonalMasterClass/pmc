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
Availability.delete_all

Rake::Task['import:school_info'].invoke

# Need this for the phone numbers and stuff.
Faker::Config.locale = 'en-AU'

20.times do |f|
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
                     first_name: "Jon",
                     last_name: 'Doe', 
                     vit_number: Faker::Number.number(6), 
                     abn_number: Faker::Number.number(11) )
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
                     first_name: 'Foo',
                     last_name: 'Bar', 
                     vit_number: Faker::Number.number(6),  
                     abn_number: Faker::Number.number(11)) 
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
                               vit_number: Faker::Number.number(6), 
                               abn_number: Faker::Number.number(11) )

  presenter.school_info = SchoolInfo.all.sample

  require 'open-uri'  
  presenter.presenter_profile = PresenterProfile.create(bio: Faker::Hacker.say_something_smart,
                                                        bio_edit: '',
                                                        status: "approved",
                                                        picture: 
                                                          open('../profilePic.png', 'wb') do |file|
                                                             open('http://lorempixel.com/300/400/animals/').read
                                                          end
                                                        )
  a.presenter = presenter
  rand(1..3).times do  
    subject = Subject.all.sample
    a.presenter.subjects << subject if !a.presenter.subjects.include? subject
  end
  

  a.save(:validate => false)
end

50.times do
    s = rand(1440)
    e = rand(s..1440)
    Availability.create(

              start_time: s,
              end_time: e,
              monday: Faker::Boolean.boolean,
              tuesday: Faker::Boolean.boolean,
              wednesday: Faker::Boolean.boolean,
              thursday: Faker::Boolean.boolean,
              friday: Faker::Boolean.boolean,
              saturday: Faker::Boolean.boolean,
              sunday: Faker::Boolean.boolean,
              presenter: Presenter.all.sample
      )
end

5.times do |f|
  a = User.new(
             user_type: :customer,
             status: :pending,
             email: "example#{f+10}@gmail.com",
             password:              "password",
             password_confirmation: "password",
             confirmed_at: Time.now )
  customer = Customer.create(phone_number:Faker::PhoneNumber.phone_number, 
                               first_name: Faker::Name.first_name,
                               last_name: Faker::Name.last_name, 
                               vit_number: Faker::Code.ean, 
                               abn_number: Faker::Code.ean )
  customer.school_info = SchoolInfo.all.sample
  a.customer = customer
  a.save(:validate => false)
end

4.times do
  booking = Booking.create(booking_date: Time.now+rand(170).days, creator: c.customer, duration_minutes: 60)  
  booking.subject = Subject.all.sample
  booking.save
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

