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
    
    it 'should have a password_digest attribute' do
      @user.should respond_to(:password_digest)
    end
    
    it 'should set the password_digest attribute' do
      @user.password_digest.should_not be_blank
    end

    it 'should encrypt passwords' do
      # why does this fail!!!!???
      @user.password_digest.should_not == @attr[:password]
    end

    describe 'has_password? method' do
      it 'should be true if the passwords match' do
        @user.has_password?(@attr[:password]).should == true
      end

      it 'should be false if the passwords do not match' do
        @user.has_password?('invalid').should be_false
      end
    end

    describe 'authenticate method' do
      it 'should return false if password does not match' do
        @user.authenticate('bogus').should be_false
      end

      it 'should return user if valid password' do
        @user.authenticate(@attr[:password]).should == @user
      end
    end
        
    describe 'User authenticate method' do
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

  end
  
  describe "micropost associations" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    
     describe "status feed" do

       it "should have a feed" do
         @user.should respond_to(:feed)
       end

       it "should include the user's microposts" do
         @user.feed.should include(@mp1)
         @user.feed.should include(@mp2)
       end

       it "should not include a different user's microposts" do
         mp3 = Factory(:micropost,
                       :user => Factory(:user, :email => Factory.next(:email)))
         @user.feed.should_not include(mp3)
       end

       it "should include the microposts of followed users" do
         followed = Factory(:user, :email => Factory.next(:email))
         mp3 = Factory(:micropost, :user => followed)
         @user.follow!(followed)
         @user.feed.should include(mp3)
       end
     end

  end
  
  describe "relationships" do

    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end

    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end
    
    it "should have a following? method" do
      @user.should respond_to(:following?)
    end

    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end
    
    it "should have an unfollow! method" do
      @followed.should respond_to(:unfollow!)
    end

    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end
    
    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end

    it "should have a followers method" do
      @user.should respond_to(:followers)
    end

    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
    
    it "should destroy associated relationships" do
      @user.follow!(@followed)
      @user.destroy
      @followed.followers.should_not include(@user)
    end
    
  end
  
end
# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  admin           :boolean         default(FALSE)
#  password_digest :string(255)
#

