FactoryGirl.define do
  factory :customer do
 		first_name "Stacey"
  	last_name "Lawler"
  	phone_number { Faker::PhoneNumber.phone_number }
  	vit_number "184539"
  	abn_number Faker::Code.ean
  	department  Faker::Company.name
  	contact_title Faker::Name.title
  end
end