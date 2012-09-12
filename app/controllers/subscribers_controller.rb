class SubscribersController < ApplicationController
  def create
    status = 0
    messages = ['', 'Email not found', 'Invalid password']
    
    params[:subscriber].reject! do |k, v|
      !%w[email password password_confirmation].include?(k)
    end

    subscriber = Subscriber.where(email: params[:subscriber][:email]).first
    if !subscriber
      status = 1
    else
      status = 2 unless subscriber.valid_password?(params[:subscriber][:password])
    end

    if status == 0
      subscriber.reset_authentication_token
      render json: { status: 0, subscriber: subscriber }
    else
      render json: { status: @status, message: messages[status] }
    end
  end

  def update
    status = 0
    messages = ['', 'Email not found', 'Invalid password']

    subscriber = Subscriber.where(email: params[:subscriber][:email]).first
    if !subscriber
      status = 1
    else
      if !subscriber.valid_password?(params[:subscriber][:current_password])
        status = 2
      else
        params[:subscriber].reject! do |k, v|
          !%w[email password password_confirmation].include?(k)
        end
        subscriber.reset_authentication_token
        status = 3 unless subscriber.update_attributes(params[:subscriber])
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

  def sign_up
    params[:subscriber].reject! do |k, v|
      !%w[email password password_confirmation].include?(k)
    end

    subscriber = Subscriber.new(params[:subscriber])

    subscriber.reset_authentication_token
    if subscriber.save
      render json: { status: 0, subscriber: subscriber }
    else
      render json: { status: 1, errors: subscriber.errors }
    end
  end

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

  def subscribe
    status = 0
    messages = ['', '', 'User id not found', 'Subscriber not found']
    
    subscriber = Subscriber.find(params[:subscriber_id])

    if subscriber
      user = User.userid(params[:user_id]).first
      if user
        subscriber.users << user
        # Save subscriber error
        status = 1 if !subscriber.save
      else
        # User id not found
        status = 2
      end
    else
      # Subscriber not found
      status = 3
    end

    if status == 0
      render json: { status: status, subscriber: subscriber }
    else
      if status == 1
        render json: { status: status, errors: subscriber.errors }
      else
        render json: { status: status, message: messages[status] }
      end
    end
  end

  def unsubscribe
    status = 0
    messages = ['', '', 'User id hasn\'t been subscribed', 'Subscriber not found']

    subscriber = Subscriber.find(params[:subscriber_id])

    if subscriber
      user = subscriber.users.userid(params[:user_id]).first
      if user
        subscriber.users -= [user]
        # Save subscriber error
        status = 1 if !subscriber.save
      else
        # User id not found
        status = 2
      end
    else
      # Subscriber not found
      status = 3
    end

    if status == 0
      render json: { status: status, subscriber: subscriber }
    else
      if status == 1
        render json: { status: status, errors: subscriber.errors }
      else
        render json: { status: status, message: messages[status] }
      end
    end
  end
end
