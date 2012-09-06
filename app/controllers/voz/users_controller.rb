class Voz::UsersController < ApplicationController
  def index
  	users = User.all
  	# binding.pry
  	if users.count > 0
  		render json: {status: "0", voz_users: users.order_by([[:userid]])}
  	else
  		render json: {status: "1", message: "No users found"}
  	end
  end

  def show
  	user = User.userid(params[:id]).first
  	if user
  		render json: {status: "0", voz_user: user.full_json}
  	else
  		render json: {status: "1", message: "User with id #{params[:id]} not found"}
  	end
  end
end
