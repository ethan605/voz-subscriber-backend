VozSubscriberBackend::Application.routes.draw do
  root :to => 'application#index'

  resource :subscribers,
           format: false,
           only: %[index create destroy update sign_up subscribe unsubscribe] do
    # get :index, as: :index
    post :create, as: :sign_in
    put :update, as: :change_password
    post :sign_up, as: :sign_up
    post :subscribe, as: :subscribe
    post :unsubscribe, as: :unsubscribe
  end

  resources :feeds, only: :index

  namespace :voz, format: false do
    resources :users, :posts, only: :index
  end
end
