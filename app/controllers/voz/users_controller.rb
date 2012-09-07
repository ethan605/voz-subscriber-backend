class Voz::UsersController < ApplicationController
  def index
    status = 0
    status_messages = ['', 'User not found', 'No user found']

  	users = User.all.order_by([[:userid]])
    if params[:userid]
      users = User.userid(params[:userid])
      if users.count == 0
        status = 1
      else
        users = users.first.full_json
      end
    else
      users = users.page(params[:page]).per(params[:per_page])
      if users.count == 0
        status = 2
      end
    end

  	if status == 0
  		render json: {status: status, users: users}
  	else
  		render json: {status: status, message: status_messages[status]}
  	end
  end
end
