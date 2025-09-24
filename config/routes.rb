Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors and load balancers.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      delete 'auth/logout', to: 'auth#logout'
      get 'auth/profile', to: 'auth#profile'
      put 'auth/profile', to: 'auth#update_profile'
      post 'auth/forgot_password', to: 'auth#forgot_password'
      put 'auth/reset_password', to: 'auth#reset_password'
    end
  end
  
  # Health check route
  root 'application#health_check'
end
