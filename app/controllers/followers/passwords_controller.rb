class Followers::PasswordsController < Devise::PasswordsController
  def change_password
  	render json: { action: 'change password' }
  end
end
