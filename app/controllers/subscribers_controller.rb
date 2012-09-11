class SubscribersController < ApplicationController
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

  def create
    subscriber = Subscriber.new(email: params[:email], password: params[:password])

    if subscriber.save
      # SubscribeMailer.welcome_email(subscriber).deliver
      render json: { status: 0, subscriber: subscriber }
    else
      render json: { status: 1, errors: subscriber.errors }
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
