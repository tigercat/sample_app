class SessionsController < ApplicationController


  def new
    @title = 'Sign in'
  end
  

  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    if user.nil?
      # Create an error message and re-render the signin form.
      @title = 'Sign in'
      flash.now[:error] = "Invalid email/password combination."
      render 'new'
    else
      sign_in user
      redirect_to user
    end    
  end


  def destroy
    sign_out
    redirect_to root_path
  end

end
