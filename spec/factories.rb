# make user objects
Factory.define :user do |user|
  user.name 'Dweeby Funk'
  user.email 'dweeb@x.com'
  user.password 'secret_pwd'
  user.password_confirmation 'secret_pwd'
end