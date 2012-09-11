class Voz::UsersController < ApplicationController
	def index
		status = 0
		messages = ['', 'User not found', 'No user found']
		User.request_host = request.protocol + request.host
		User.request_host += ":#{request.port}" if request.host == "localhost"

		if params[:userid]
			user = User.userid(params[:userid]).first
			if user
				users = user.full_json
			else
				# User not found
				status = 1
			end
		else
			users = User.all.order_by([:userid])
			users = users.search(params[:q]).page(params[:page]).per(params[:per_page])

			# No user found
			status = 2 if users.count == 0
		end

		if status == 0
			render json: { status: status, results: users.count, users: users }
		else
			render json: { status: status, message: messages[status] }
		end
	end
end
