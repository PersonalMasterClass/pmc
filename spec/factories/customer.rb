FactoryGirl.define do
  factory :customer do
 		first_name "John"
  	last_name "Doe"
  	phone_number { Faker::PhoneNumber.phone_number }
  	vit_number Faker::Code.ean
  	abn_number Faker::Code.ean
  	department  Faker::Company.name
  	contact_title Faker::Name.title
    email { Faker::Internet.email }
  end
end