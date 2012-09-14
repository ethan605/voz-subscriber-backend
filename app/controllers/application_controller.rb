class ApplicationController < ActionController::Base
  # protect_from_forgery
  def index
    user = User.skip(rand(User.count-1)).first
    post = Post.skip(rand(Post.count-1)).first
    subscriber = Subscriber.skip(rand(Subscriber.count-1)).first

    request_host = request.protocol + request.host

    request_host += ":#{request.port}" if request.host == 'localhost'

    api = {
      'APIs' => {
        'Generate RSS Feeds for all posts (order by newest first)' => {
          "GET" => "#{request_host}/feeds.rss"
        },
        'Generate RSS Feeds for a subscriber by email (order by newest first)' => {
          "GET" => "#{request_host}/feeds.rss?subscriber=#{subscriber.email}"
        },
        'Generate RSS Feeds for a Voz user by username (order by newest first)' => {
          "GET" => "#{request_host}/feeds.rss?user=#{user.username}"
        },
        'Subscriber sign up' => {
          "POST" => "#{request_host}/subscribers/sign_up",
          "params" => {
            "email" => "<subscriber's email>",
            "password" => "<subscriber's password>",
            "password_confirmation" => "<subscriber's confirmed password>"
          }
        },
        'Subscriber sign in ' => {
          "POST" => "#{request_host}/subscribers",
          "params" => {
            "email" => "<subscriber's email>",
            "password" => "<subscriber's password>"
          }
        },
        'Subscriber change password ' => {
          "PUT" => "#{request_host}/subscribers",
          "params" => {
            "email" => "<subscriber's email>",
            "current_password" => "<subscriber's current password>",
            "password" => "<subscriber's new password>",
            "password_confirmation" => "<subscriber's confirmed password>"
          }
        },
        'Subscribe to an user' => {
          "POST" => "#{request_host}/subscribers/subscribe",
          "params" => {
            "subscriber_id" => "<subscriber's id>",
            "user_id" => "<subscribed user's id>",
            "auth_token" => "<subscriber's login authentication token>"
          }
        },
        'Unsubscribe to an user' => {
          "POST" => "#{request_host}/subscribers/unsubscribe",
          "params" => {
            "subscriber_id" => "<subscriber's id>",
            "user_id" => "<subscribed user's id>",
            "auth_token" => "<subscriber's login authentication token>"
          }
        },
        'Generate RSS Feeds for a Voz user by username (order by newest first)' => {
          "GET" => "#{request_host}/feeds.rss?user=#{user.username}"
        },
        'List all users (order by userid)' => {
          "GET" => "#{request_host}/voz/users?page=1&per_page=10"
        },
        'Find users by name' => {
          "GET" => "#{request_host}/voz/users?q=#{user.username}&page=1&per_page=10"
        },
        'Find an user by userid' => {
          "GET" => "#{request_host}/voz/users?userid=#{user.userid}"
        },
        'List all posts (order by newest first)' => {
          "GET" => "#{request_host}/voz/posts?page=1&per_page=10"
        },
        'Find posts by title & spoiler' => {
          "GET" => "#{request_host}/voz/posts?q=Say&page=1&per_page=10"
        }
      },
      'STATS' => {
        'Total subscribers' => Subscriber.count,
        'Total users' => User.count,
        'Total posts' => Post.count
      }
    }
    render json: api
  end
end
