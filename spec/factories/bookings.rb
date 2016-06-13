FactoryGirl.define do
  factory :booking do
    customer_id 1
    presenter_id 1
    booking_date DateTime.now
    duration_minutes 1
    cancellation_message "MyString"
    shared false
    approval 1
    subject_id 1
    presenter_paid false
  end
end
