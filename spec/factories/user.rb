FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "helloworld"
    password_confirmation "helloworld"
    confirmed_at Time.now
  end
end



