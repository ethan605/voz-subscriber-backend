VozSubscriberBackend::Application.routes.draw do
  devise_for :dev_tests

  root :to => 'application#index'

  resource :followers,
           format: false,
           only: %[create destroy update sign_up] do
    post :create,     as: :sign_in
    delete :destroy,  as: :sign_out
    put :update,      as: :change_password
    post :sign_up,    as: :sign_up
  end

  resources :subscribers, only: :index, format: false do
    collection do
      post :create
      post :subscriber
      post :unsubscribe
    end
  end

  resources :feeds, only: :index

  namespace :voz, format: false do
    resources :users, :posts, only: :index
  end
end
