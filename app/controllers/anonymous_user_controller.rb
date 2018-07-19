class AnonymousUserController < ApplicationController
  layout 'single_card'
  def new
    @user = User.new(password: 'fake_password')
  end

  # given a username, create a one time user and allow it to create events
  def create
    allow_params_authentication!
    anon_params = AnonymousUser.attributes(whitelist_params)
    @user = User.new(anon_params)
    if @user.save_with_captcha
      # since we're circumventing the usual Devise flow here
      # we need to sign in like this
      sign_in @user
      warden.authenticate!(scope: :user)
      warden.set_user @user
      redirect_to new_event_path
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  private
  def whitelist_params
    params.permit(:captcha, :captcha_key)
  end
end
