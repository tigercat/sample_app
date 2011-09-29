require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:name => 'Example User',
              :email => 'user@example.com',
              :password => 'secret',
              :password_confirmation => 'secret'}
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


  describe 'password validations' do
  
    it 'should require a password' do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end
    
    it 'should require a matching password confirmation' do
      User.new(@attr.merge(:password_confirmation => "mismatch")).
        should_not be_valid
    end

    it 'should reject short passwords' do
      short = 'a'*5
      User.new(@attr.merge(:password=>short, :password_confirmation=>short)).
        should_not be_valid
    end

    it 'should reject long passwords' do
      long = 'a'* 41
      User.new(@attr.merge(:password=>long, :password_confirmation=>long)).
        should_not be_valid
    end
  end
  
  
  describe 'password encryption' do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it 'should have an encrypted password attribute' do
      @user.should respond_to(:encrypted_password)
    end
    
    it 'should set the encrypted_password attribute' do
      @user.encrypted_password.should_not be_blank
    end

    it 'should encrypt passwords' do
      @user.encrypted_password.should_not == @user.password
    end

    describe 'has_password? method' do
      it 'should be true if the passwords match' do
        @user.has_password?(@attr[:password]).should be_true
      end

      it 'should be false if the passwords do not match' do
        @user.has_password?('invalid').should be_false
      end
    end
        
    describe 'authenticate method' do
      it 'should return nil if password does not match' do
        User.authenticate(@attr[:email], 'bogus').should be_nil
      end

      it 'should return nil if email does not exist' do
        User.authenticate('none@x.com', @attr[:password]).should be_nil
      end

      it 'should return user if valid email and password' do
        User.authenticate(@attr[:email], @attr[:password]).should == @user
      end
    end

    describe 'authenticate with salt method' do
      it 'should return nil if salt does not match' do
        User.authenticate_with_salt(@user[:id], 'bogus').should be_nil
      end

      it 'should return nil if id does not exist' do
        User.authenticate_with_salt(-1, @user.salt).should be_nil
      end

      it 'should return user if valid id and salt' do
        User.authenticate_with_salt(@user.id, @user.salt).should == @user
      end
    end
  end
  
end
# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#

