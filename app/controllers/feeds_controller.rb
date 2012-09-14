class FeedsController < ApplicationController
  def index
    status = 0
    messages = ['', 'Subscriber not found', 'User id not found', 'No post found']

    req = 0
    req = 1 if params[:subscriber]
    req = 2 if params[:user]

    feed_url_prefix = "#{request.protocol}#{request.host}"
    feed_url_prefix += ":#{request.port}" if request.host == "localhost"
    feed_url_prefix += "/feeds.rss"

    @feed_url = feed_url_prefix
    @feed_ref = 'all posts'
    @posts = Post.all

    case req
    when 1    # 'subscriber' available
      subscriber = Subscriber.email(params[:subscriber]).first
      if subscriber
        @feed_url = "#{feed_url_prefix}?subscriber=#{params[:subscriber]}"
        @feed_ref = "subscriber #{subscriber.email}"
        @posts = subscriber.subscribed_posts
        
        # Subscriber has no subscribed user
        status = 3 if !@posts
      else
        # Subscriber not found
        status = 1
      end
    when 2    # 'user' available
      user = User.username(params[:user]).first
      if user
        @feed_url = "#{feed_url_prefix}?user=#{params[:user]}"
        @feed_ref = "Voz user #{user.username}"
        @posts = user.posts
      else
        status = 2
      end
    end

    status = 3 if status == 0 && @posts.count == 0
    @posts = @posts.order_by([:postid, :desc]).page(1).per(30) if status == 0

    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
