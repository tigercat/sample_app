require 'spec_helper'

describe "FollowUnfollows" do
  before(:each) do
    @user = Factory(:user)
    integration_sign_in(@user)
    # create another user
    @user2 = Factory(:user, :email => Factory.next(:email))
    visit user_path(@user2)
  end
  
  it "should start up not following a user" do
    response.should have_selector("form div input", :value => "Follow")
  end

  it "should follow a user" do
    click_button
    response.should have_selector("form div input", :value => "Unfollow")
  end

  it "should unfollow a user" do
    click_button
    click_button
    response.should have_selector("form div input", :value => "Follow")
  end
end
