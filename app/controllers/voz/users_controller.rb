class Voz::UsersController < ApplicationController
  def index
  	voz_users = Voz::User.all
  	if voz_users.count > 0
  		render json: {status: "0", voz_users: voz_users}
  	else
  		render json: {status: "1", message: "No users found"}
  	end
  end

  def show
  	voz_user = Voz::User.vozid(params[:id]).first
  	if voz_user
  		render json: {status: "0", voz_user: voz_user}
  	else
  		render json: {status: "1", message: "User with id #{params[:id]} not found"}
  	end
  end
end
