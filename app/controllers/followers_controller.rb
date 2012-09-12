class FollowersController < ApplicationController
  def create
    render json: { action: 'sign in' }
  end

  def destroy
  end

  def update
  end

  def sign_up
    follower = Follower.new(params[:follower])

    if follower.save
      render json: { status: 0, follower: follower }
    else
      render json: { status: 1, errors: follower.errors }
    end
  end
end
