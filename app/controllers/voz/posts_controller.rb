class Voz::PostsController < ApplicationController
	def index
		posts = User.userid(params[:user_id]).first.posts
		posts = posts.order_by([[:postid, :desc]]).page(params[:page]).per(params[:per_page])

		if posts.count > 0
			render json: { status: 0, posts: posts }
		else
			render json: { status: 1, message: "No post found for user id #{params[:user_id]}"}
		end
	end
end
