require "rails_helper"

feature "Log in as", :type => :feature  do
  scenario "Admin" do
    @admin = User.create!(
             user_type: :admin,
             status: :approved,
             email: "rosemary@gmail.com",
             password:              "password",
             password_confirmation: "password",
             confirmed_at: Time.now)

    visit "/users/sign_in"

    fill_in "Email", :with => @admin.email
    fill_in "Password", :with => @admin.password

    click_button "Log in"

    expect(page).to have_text("Management Console")
  end
  scenario "School" do
    @customer = User.create!(
             user_type: :customer,
             status: :approved,
             email: "arandomschool@gmail.com",
             password:              "password",
             password_confirmation: "password",
             confirmed_at: Time.now)

    visit "/users/sign_in"

    fill_in "Email", :with => @customer.email
    fill_in "Password", :with => @customer.password

    click_button "Log in"

    expect(page).to have_text("School Dashboard")
  end
  scenario "Presenter" do
    @presenter = User.create!(
             user_type: :presenter,
             status: :approved,
             email: "arandompresenter@gmail.com",
             password:              "password",
             password_confirmation: "password",
             )

    visit "/users/sign_in"

    fill_in "Email", :with => @presenter.email
    fill_in "Password", :with => @presenter.password

    click_button "Log in"
    # This is what we want because it shows a persisted presenter object is saved
    # 
    expect(page).to have_text("You have to confirm your email address before continuing.")
  end
end