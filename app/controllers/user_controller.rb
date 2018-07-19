class UserController < ApplicationController
  layout 'single_card'
  before_action :set_user, only: [:show, :edit, :update, :destroy, :make_admin]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :make_admin]
  before_action :authorised_user?, only: [:edit, :update, :destroy]
  before_action :admin_user?, only: [:make_admin, :destroy]

  # We don't do the case insensitive search
  # in SQL as it is implementation dependent,
  # i.e. different from sqlite3 to postgres.
  # Therefore we do an initial sort in sql
  # and a subsequent one in Ruby.
  def index
    @users = User.where(is_anonymous: false).order(:username).sort_by { |u| u.username.downcase }
  end

  def new
  end

  def create
  end

  def show
    @calendar = Calendar.with_hidden(@user)
  end

  def edit
  end

  def update
    if @user.update(user_whitelist)
      redirect_to @user, notice: I18n.t('layouts.updated.basic_message')
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      redirect_to users_path, notice: 'User deleted'
    else
      redirect_to :back, status: :service_unavailable
    end
  end

  def make_admin
    if @user.make_admin
      redirect_to users_path, notice: "User #{@user.username} is now an admin user"
    else
      redirect_to users_path, alert: 'Error! User could not be updated...'
    end
  end

  private
  def authorised_user?
    unless current_user.can_edit? @user
      redirect_to users_path, notice: 'You are not permitted to edit this user!'
    end
  end

  def admin_user?
    unless current_user.is_admin?
      redirect_to users_path, notice: 'Only admin users can perform this action!'
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_whitelist
    params.require(:user).permit(:email, :password, :username, :is_admin, :description)
  end
end
