class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update, :index, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => [:destroy]
  before_filter :not_logged_in, :only => [:new, :create]

  def new
    @user = User.new
    @title = 'Sign up'
  end
  
  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Welcome to the Sample App"
      sign_in(@user)
      redirect_to @user
    else
      @title = 'Sign up'
      render 'new'
    end
  end
  
  def edit
#    @user = User.find(params[:id])
    @title = "Edit user"
  end
  
  def update
#    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end
  
  def destroy
    user = User.find(params[:id])
    if current_user == user
      flash[:error] = "Cannot delete oneself"
    else
      flash[:success] = "User destroyed."
      user.destroy
    end
    redirect_to users_path
  end

  
  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
    
    def not_logged_in
      flash[:error] = "You are aleady logged in."
      redirect_to(root_path) unless !signed_in?
    end
end
