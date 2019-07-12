Rails.application.routes.draw do
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users
  resource :session, only: [:new, :create, :destroy]


  get 'welcome/index', {to: 'welcome#index', as: 'root'}
  get '/groceries', {to: 'groceries#index'}
  post '/groceries', {to: 'groceries#create'}

end
