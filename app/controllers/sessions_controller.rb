class SessionsController < Devise::SessionsController
  include ActionController::MimeResponds
  include AuthConcern

  skip_before_action :authenticate_user_from_token!, only: [:create]
  before_action :ensure_params_exist, only: [:create]

  def create
    resource = User.find_by(email: params[:user_login][:email])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:user_login][:password])
      sign_in(:user, resource)

      render(json: resource, serializer: UserSerializer, root: false)
      return
    end

    invalid_login_attempt
  end

  def destroy
    sign_out(resource_name)
    render(json: { success: true })
  end


  private

  def invalid_login_attempt
    warden.custom_failure!
    render(json: { success: false, message: 'Incorrect email and/or password'}, status: 401)
  end

  def ensure_params_exist
    return unless params[:user_login].blank? || params[:user_login][:email].blank? || params[:user_login][:password].blank?

    render(json: { success: false, message: 'Malformed request' }, status: 422)
  end
end
