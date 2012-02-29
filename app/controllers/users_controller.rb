class UsersController < ApplicationController
  before_filter :authenticate_researcher_or_player!
  before_filter :assign_user

  respond_to :html, :json

  def index
    @users = User.where("username like ?", "#{params[:term]}%")
    
    respond_with(@users) do |format|
      format.json { render :json => @users.collect(&:username) }
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user), :notice => "Profile updated!"
    else
      render :edit
    end
  end

  def update_password
    if @user.update_attributes(params[:user])
      sign_in @user, :bypass => true
      redirect_to user_path(@user), :notice => "Profile updated!"
    else
      render :edit
    end
  end

  private

  def assign_user
    @user = current_user
  end
end
