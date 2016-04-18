FactoryGirl.define do
  factory :presenter do
  	first_name "John"
  	last_name "Doe"
  	phone_number { Faker::PhoneNumber.phone_number }
  	vit_number Faker::Code.ean
  	abn_number Faker::Code.ean
  end
end