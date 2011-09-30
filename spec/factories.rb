# make user objects
Factory.define :user do |user|
  user.name 'Dweeby Funk'
  user.email 'df@example.com'
  user.password 'password'
  user.password_confirmation 'password'
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.association :user
end
