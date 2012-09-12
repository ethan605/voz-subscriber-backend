class Followers::SessionsController < Devise::SessionsController
  def new
  	render json: { action: 'sign in' }
  end

  def destroy
  	render json: { action: 'sign out' }
  end

  def sign_in
  	render json: { action: 'sign in' }
  end
end
