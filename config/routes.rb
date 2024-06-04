Rails.application.routes.draw do
  root 'uploads#new'
  resources :uploads, only: [:create]
  get 'uploads/demo', to: 'uploads#demo', as: 'demo'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
