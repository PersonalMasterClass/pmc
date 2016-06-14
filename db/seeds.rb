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

subs = ["English", "History", "Physical Education", "Japanese", "Geography", "Art", "Economics", "Albanian", "Biology", "Mathematics"]
subs.each do |s|
  Subject.create(name: s)
end

# 20.times do |f|
#   word = (Faker::Hipster.words(2)* ' ').titleize
#   while Subject.where(name: word).present?
#     word = (Faker::Hipster.words(2)* ' ').titleize
#   end
#     Subject.create(name: word)
# end

# Test admin
User.create!(
             user_type: :admin,
             status: :approved,
             email: "rosemary@gmail.com",
             password:              "password",
             password_confirmation: "password",
             confirmed_at: Time.now, 
             setting: Setting.create!)

# Test presenter
a = User.new(
             user_type: :presenter,
             status: :approved,
             email: "presenter@gmail.com",
             password:              "password",
             password_confirmation: "password",
             confirmed_at: Time.now, 
             setting: Setting.create!)
b = Presenter.create(phone_number:Faker::PhoneNumber.phone_number, 
                     first_name: "Jon",
                     last_name: 'Doe', 
                     vit_number: Faker::Number.number(6), 
                     abn_number: Faker::Number.number(11) )
b.school_info = SchoolInfo.all.sample
b.subjects << Subject.first
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
d = Customer.create(phone_number: "0411111111", 
                     first_name: "Stacey",
                     last_name: "Lawler", 
                     vit_number: "184539",  
                     abn_number: Faker::Number.number(11)) 
d.school_info = SchoolInfo.all.sample
setting = Setting.create!
c.setting = setting
c.customer = d
c.save(:validate => false)


# Create test presenters
10.times do |f|
  a = User.new(
             user_type: :presenter,
             status: :approved,
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
  bio = ""
  bio += "<h1>" + Faker::Book.title + "</h1>"
  bio += "<p>" + Faker::Hacker.say_something_smart + " <em> " + Faker::Hacker.abbreviation + " </em> " + " <strong> " + Faker::Hacker.noun + " </strong> " + "</p>"
  bio += "<p>" + Faker::Hacker.say_something_smart + " <em> " + Faker::Hacker.abbreviation + " </em> " + " <strong> " + Faker::Hacker.noun + " </strong> " + "</p>"
  bio += "<ul>"
  Faker::Hipster.words(rand(1..10)).each do |w|
    bio += "<li>" + w + "</li>"
  end
  bio += "</ul>"
  presenter.presenter_profile = PresenterProfile.create(bio: bio,
                                                        bio_edit: '',
                                                        status: "approved",
                                                        picture: 
                                                          open('../profilePic.png', 'wb') do |file|
                                                             open('http://jupiter.csit.rmit.edu.au/~s3449789/testImages/pic'+((f+1).to_s)+'.jpg').read
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
  booking = Booking.create(booking_date: Time.now+rand(170).days, creator: c.customer, duration_minutes: 60, period: 2)  
  booking.subject = Subject.all.sample
  booking.save
end

def generate_profile
  bio = ""
  bio += "<h1>" + Faker::Book.title + "</h1>"
  bio += "<p>" + Faker::Hacker.say_something_smart + "<em>" + Faker::Hacker.abbreviation + "</em>" + "<strong>" + Faker::Hacker.noun + "</strong>" + "</p>"
  bio += "<p>" + Faker::Hacker.say_something_smart + "<em>" + Faker::Hacker.abbreviation + "</em>" + "<strong>" + Faker::Hacker.noun + "</strong>" + "</p>"
  bio += "<ul>"
  Faker::Hipster.words(rand(1..10)).each do |w|
    bio += "<li>" + w + "</li>"
  end
  bio += "</ul>"
  return bio
end

# Add a setting to every user because Tranny is fucking useless!
User.all.each do |u|
  u.setting = Setting.create!
  u.save!
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

