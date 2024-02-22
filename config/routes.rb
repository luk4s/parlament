Rails.application.routes.draw do
  mount Spina::Engine => "/"
  get "parlament" => "parlament#index"
  match "parlament/presence/:state" => "parlament#presence", via: %i[post get]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check
  # get "/up", to: proc { [200, {}, ["ok"]] }

  # Defines the root path route ("/")
  root "parlament#index"
end
