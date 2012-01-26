class UserController < ApplicationController
  before_filter :login_required
  before_filter :find_user

  def show
    @authmethods_left = ['facebook', 'mturk']
    authmethods_used = @user.authmethods.map{|am| am.auth_type }
    @authmethods_left -= authmethods_used
  end

  def edit
  end

  #TODO merge with #complete
  def create
    @user = User.new
    @user.username = params[:username]
    @user.email = params[:email]
    @user.initial_password = params[:password]
    @user.initial_password_confirmation = params[:confirm_password]
    @user.complete = true
    @user.role = (params[:is_researcher]=='on' ? :researcher : :player)
    @user.save :newuser

    unless @user.errors.empty?
      render :new and return
    end

    @user.sign_in!(session)
    redirect_to root_url, :notice => "Created you in the system!"
  end

  def complete
    #TODO what for?
    login_required

    u = current_user
    u.username = params[:username]
    u.initial_password = params[:password]
    u.initial_password_confirmation = params[:confirm_password]
    u.email = params[:email]
    u.complete = true
    u.save :newuser

    unless u.errors.empty?
      render :edit and return
    end

    redirect_to curent_user, :notice => "You completed your profile!"
  end

  #TODO merge in #update
  def info
    u = current_user
    u.age = params[:age]
    u.location = params[:location]
    u.bio = params[:bio]
    u.gender = params[:gender]=='1'
    u.save!

    redirect_to curent_user, :notice => "You edited your profile!"
  end

  #TODO merge in #update
  def researcher
    u = current_user
    u.location = params[:location]
    u.telephone = params[:telephone]
    u.institution = params[:institution]
    u.save

    redirect_to curent_user, :notice => "You edited your profile!"
  end

  #TODO merge in #update
  def password
    u = current_user
    u.initial_password = params[:password]
    u.initial_password_confirmation = params[:confirm_password]
    u.save :newpass

    unless u.errors.empty?
      render :edit and return
    end

    redirect_to curent_user, :notice => "You changed your password!"
  end

  private

  def find_user
    @user = User.find(params[:id])
    redirect_to user_path, :error => "No user exists!" unless @user
  end
end
