Rails.application.routes.draw do
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users
  resource :session, only: [:new, :create, :destroy]


  get 'welcome/index', {to: 'welcome#index', as: 'root'}
  get '/forgot_password', {to: 'welcome#forgot_password', as: 'forgot_password'}
  post '/forgot_password', {to: 'welcome#send_email', as: 'send_email'}
  get '/password_reset', {to: 'welcome#password_reset', as: 'password_reset'}
  post '/password_reset', {to: 'welcome#password_reset'}
  get '/setting', {to: 'welcome#setting', as: 'setting'}
  post '/setting', {to: 'welcome#create', as: 'password_update'}
  patch '/setting', {to: 'users#update', as: 'user_update'}
  get '/groceries', {to: 'groceries#index'}
  post '/groceries', {to: 'groceries#create'}

  match(
    "/delayed_job",
    to: DelayedJobWeb,
    anchor: false,
    via: [:get, :post]
  )

end
