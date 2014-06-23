FactoryGirl.define do
  factory :user do
    email "fake_email@professionalsteve.com"
    password "itsasecret"
    password_confirmation "itsasecret"
  end
end
