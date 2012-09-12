class FollowersController < ApplicationController
  def create
    status = 0
    messages = ['', 'Email not found', 'Invalid password']
    
    params[:follower].reject! do |k, v|
      !%w[email password password_confirmation].include?(k)
    end

    follower = Follower.where(email: params[:follower][:email]).first
    if !follower
      status = 1
    else
      status = 2 unless follower.valid_password?(params[:follower][:password])
    end

    if status == 0
      follower.reset_authentication_token
      render json: { status: 0, follower: follower }
    else
      render json: { status: @status, message: messages[status] }
    end
  end

  def update
    status = 0
    messages = ['', 'Email not found', 'Invalid password']

    follower = Follower.where(email: params[:follower][:email]).first
    if !follower
      status = 1
    else
      if !follower.valid_password?(params[:follower][:current_password])
        status = 2
      else
        params[:follower].reject! do |k, v|
          !%w[email password password_confirmation].include?(k)
        end
        follower.reset_authentication_token
        status = 3 unless follower.update_attributes(params[:follower])
      end
    end
    
    if status == 0
      render json: { status: status, follower: follower }
    else
      if status == 3
        render json: { status: status, errors: follower.errors }
      else
        render json: { status: status, message: messages[status] }
      end
    end
  end

  def sign_up
    params[:follower].reject! do |k, v|
      !%w[email password password_confirmation].include?(k)
    end

    follower = Follower.new(params[:follower])

    follower.reset_authentication_token
    if follower.save
      render json: { status: 0, follower: follower }
    else
      render json: { status: 1, errors: follower.errors }
    end
  end
end
