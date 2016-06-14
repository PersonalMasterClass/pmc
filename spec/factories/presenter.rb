FactoryGirl.define do
  factory :presenter do
  	first_name "Stacey"
  	last_name "Lawler"
  	phone_number { Faker::PhoneNumber.phone_number }
  	vit_number "184539"
  	abn_number Faker::Code.ean
  end
end