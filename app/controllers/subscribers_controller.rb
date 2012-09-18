class SubscribersController < ApplicationController
  # GET /subscribers
  def index
    status = 0
    messages = ['', 'Subscriber not found', 'No subscriber found']

    subscribers = Subscriber.all
    subscribers = subscribers.page(params[:page]).per(params[:per_page])
    subscribers = subscribers.search(params[:q])

    # No user found
    status = 2 if subscribers.count == 0

    if status == 0
      render json: { status: status, results: subscribers.count, subscribers: subscribers }
    else
      render json: { status: status, message: messages[status] }
    end
  end

  # POST /subscribers
  def create
    status = 0
    messages = ['', 'Email not found', 'Invalid password']
    
    # Ensure only expected params are kept
    params.reject! do |k, v|
      !%w[email password password_confirmation].include?(k)
    end

    subscriber = Subscriber.where(email: params[:email]).first
    if !subscriber
      status = 1
    else
      status = 2 unless subscriber.valid_password?(params[:password])
    end

    if status == 0
      render json: { status: status, subscriber: subscriber }
    else
      render json: { status: status, message: messages[status] }
    end
  end

  # PUT /subscribers
  def update
    status = 0
    messages = ['', 'Subscriber id not found', 'Invalid password']

    subscriber = Subscriber.find(params[:subscriber_id])
    
    if !subscriber
      status = 1
    else
      if !subscriber.valid_password?(params[:current_password])
        status = 2
      else
        params.reject! do |k, v|
          !%w[password password_confirmation].include?(k)
        end
        status = 3 unless subscriber.update_attributes(params)
      end
    end
    
    if status == 0
      render json: { status: status, subscriber: subscriber }
    else
      if status == 3
        render json: { status: status, errors: subscriber.errors }
      else
        render json: { status: status, message: messages[status] }
      end
    end
  end

  # POST /subscribers/sign_up
  def sign_up
    params.reject! do |k, v|
      !%w[email password password_confirmation].include?(k)
    end

    subscriber = Subscriber.new(params)

    if subscriber.save
      Thread.new { SubscribeMailer.welcome_email(subscriber).deliver }
      render json: { status: 0, subscriber: subscriber }
    else
      render json: { status: 1, errors: subscriber.errors }
    end
  end

  # POST /subscribers/subscribe
  def subscribe
    ensure_authenticate do |subscriber|
      status = 0
      messages = ['', 'Authentication failed',
                  'Subscriber save error', 'User id not found']

      user = User.userid(params[:user_id]).first
      if user
        subscriber.users << user
        # Subscriber save error
        status = 2 if !subscriber.save
      else
        # User id not found
        status = 3
      end

      if status == 0
        Thread.new {
          User.crawl(user.userid, 0, true) unless Crawler::Crawler.mutex.include?(user.userid)
        }
        render json: { status: status, subscriber: subscriber }
      else
        if status == 2
          render json: { status: status, errors: subscriber.errors }
        else
          render json: { status: status, message: messages[status] }
        end
      end
    end
  end

  # POST /subscribers/unsubscribe
  def unsubscribe
    ensure_authenticate do |subscriber|
      status = 0
      messages = ['', 'Authentication failed',
                  'Subscriber save error', 'User id hasn\'t been subscribed']

      user = subscriber.users.userid(params[:user_id]).first
      if user
        subscriber.users -= [user]
        # Subscriber save error
        status = 2 if !subscriber.save
      else
        # User id not found
        status = 3
      end

      if status == 0
        render json: { status: status, subscriber: subscriber }
      else
        if status == 2
          render json: { status: status, errors: subscriber.errors }
        else
          render json: { status: status, message: messages[status] }
        end
      end
    end
  end

  private
  def ensure_authenticate
    status = 0
    messages = ['', 'Authentication failed']
    param_hmac = params[:hmac]
    subscriber = Subscriber.find(params[:subscriber_id])

    if subscriber && param_hmac
      params.reject! do |k, v|
        !%w[subscriber_id user_id].include?(k)
      end

      digest = OpenSSL::Digest::Digest.new('sha256')
      private_key = subscriber.private_key
      message = [request.path, request.method, params]
      message = Subscriber.convert_params(message)
      hmac = OpenSSL::HMAC.hexdigest(digest, private_key.to_s, message)

      status = 1 unless param_hmac && hmac == param_hmac
    else
      status = 1
    end

    if status == 0
      yield(subscriber)
    else
      render json: { status: 1, message: 'Authentication failed' }
    end
  end
end
