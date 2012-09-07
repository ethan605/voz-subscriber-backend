class ApplicationController < ActionController::Base
	# protect_from_forgery
	def index
		user = User.skip(rand(User.count-1)).first
		post = Post.skip(rand(Post.count-1)).first

		request_host = request.host

		if request_host == "localhost"
			request_host = "localhost:3000"
		end

		doc = {
			'APIs' => {
				'List all users (order by userid)' => [
					"http://#{request_host}/voz/users?page=1&per_page=10"
				],
				'Find users by name' => [
					"http://#{request_host}/voz/users?q=#{user.username}&page=1&per_page=10",
					"q={ascii|vietnamese}"
				],
				'Find an user by userid' => [
					"http://#{request_host}/voz/users?userid=#{user.userid}"
				],
				'List all posts (order by newest first)' => [
					"http://#{request_host}/voz/posts?page=1&per_page=10"
				],
				'Find posts by title & spoiler' => [
					"http://#{request_host}/voz/posts?q=Say&page=1&per_page=10",
					"q={ascii|vietnamese}"
				]
			},
			'STATS' => [
				'all users' => User.count,
				'all posts' => Post.count
			]
		}
		render json: doc
	end
end
