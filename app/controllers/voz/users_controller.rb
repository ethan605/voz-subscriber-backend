class Voz::UsersController < ApplicationController
  def index
    status = 0
    messages = ['', 'User not found', 'No user found']

  	users = User.all.order_by([[:userid]])
    if params[:userid]
      user = User.userid(params[:userid]).first
      if user
        status = 1
      else
        users = user.full_json
      end
    else
      users = users.page(params[:page]).per(params[:per_page])
      users = users.search(params[:q])
      if users.count == 0
        status = 2
      end
    end

  	if status == 0
  		render json: {status: status, users: users}
  	else
  		render json: {status: status, message: messages[status]}
  	end
  end
end
