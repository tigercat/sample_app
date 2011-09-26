require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:name => 'Example User', :email => 'user@example.com'}
  end
  
  it 'should create a new instance given valid attributes' do
    User.create!(@attr)
  end
  
  it 'should require a name' do
    no_name_user = User.new(@attr.merge(:name=>""))
    no_name_user.should_not be_valid
  end

  it 'should require an email address' do
    no_email_user = User.new(@attr.merge(:email=>""))
    no_email_user.should_not be_valid
  end
  
  it 'should not allow names that are too long' do
    long_name_user = User.new(@attr.merge(:name => 'a'*51))
    long_name_user.should_not be_valid
  end
  
  it 'should accept valid email addresses' do
    %w[user@x.com THE_U@x.y.org f.l@x.jp].each do |address|
      User.new(@attr.merge(:email => address)).should be_valid
    end
  end

  it 'should not accept invalid email addresses' do
    %w[user@com user_at.org f.l@x.].each do |address|
      User.new(@attr.merge(:email => address)).should_not be_valid
    end
  end
  
  it 'should reject duplicate email addresses' do
    User.create!(@attr)
    User.new(@attr).should_not be_valid
  end

  it 'should reject email addresses with same case' do
    User.create!(@attr)
    User.new(@attr.merge(:email => @attr[:email].upcase)).should_not be_valid
  end
end
# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

