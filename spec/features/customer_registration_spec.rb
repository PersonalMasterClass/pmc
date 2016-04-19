require "rails_helper"

feature "Submit Customer Registration Form", :type => :feature  do
  scenario "User registers as a customer" do
    visit "/registration/customers"

    fill_in "Email", :with => Faker::Internet.email
    fill_in "Password", :with => "password"
    fill_in "Password confirmation", :with => "password"
    fill_in "First name", :with => Faker::Name.first_name
    fill_in "Last name", :with => Faker::Name.last_name
    fill_in "Phone number", :with => Faker::PhoneNumber.phone_number
    fill_in "Vit number", :with => Faker::Code.ean
    fill_in "Department", :with => Faker::Company.name
    fill_in "Contact title", :with => Faker::Name.title 

    click_button "Sign up"

    expect(page).to have_text("Your application has been submitted for approval. Please check your email to confirm your email.")
  end
end