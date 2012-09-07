class Voz::UsersController < ApplicationController
	def index
		status = 0
		messages = ['', 'User not found', 'No user found']

		users = User.all.order_by([[:userid]])
		if params[:userid]
			user = User.userid(params[:userid]).first
			if user
				users = user.full_json
			else
				status = 1  # user not found
			end
		else
			users = users.page(params[:page]).per(params[:per_page])
			users = users.search(params[:q])

			# No user found
			status = 2 if users.count == 0
		end

		if status == 0
			render json: {status: status, results: users.count, users: users }
		else
			render json: {status: status, message: messages[status] }
		end
	end
end
