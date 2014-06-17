FactoryGirl.define do
  # Define a basic devise user.
  factory :user do
    email "fake_email@professionalsteve.com"
    password "itsasecret"
    password_confirmation "itsasecret"
  end
end
