class Voz::PostsController < ApplicationController
	def index
		status = 0
		messages = ['', 'User not found', 'User has no post', 'No post found']

		if params[:userid]
			# Find posts by userid
			user = User.userid(params[:userid]).first
			if user
				posts = user.posts
				status = 2 if posts.count == 0
			else
				status = 1
			end
		else
			# Show all posts
			posts = Post.all
			posts = posts.search(params[:q])
			status = 3 if posts.count == 0
		end

		if status == 0
			# Paging results
			posts = posts.order_by([[:postid, :desc]]).page(params[:page]).per(params[:per_page])
			render json: { status: status, results: posts.count, posts: posts }
		else
			render json: { status: 1, message: messages[status] }
		end
	end
end
