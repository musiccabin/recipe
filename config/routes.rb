Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users, only: [:new, :create] do
    resource :mealplan, except: [:new, :index]
  end
  resource :session, only: [:new, :create, :destroy]
  resources :myrecipes do
    resources :reviews do
      resources :likes
      resources :reviews
    end
    resources :ingredients
    resources :completions
    resources :favourites
  end


  get 'welcome/index', {to: 'welcome#index', as: 'root'}
  get '/forgot_password', {to: 'users#forgot_password', as: 'forgot_password'}
  post '/forgot_password', {to: 'users#send_email', as: 'send_email'}
  get '/password_reset', {to: 'users#password_reset', as: 'password_reset'}
  post '/password_reset', {to: 'users#password_reset'}
  get '/setting', {to: 'users#setting', as: 'setting'}
  patch '/setting', {to: 'users#update', as: 'user_update'}
  get '/groceries', {to: 'groceries#index'}
  post '/groceries', {to: 'groceries#create'}
  # post '/myrecipe_new', {to: 'myrecipe#add_tag', as: 'add_tag'}

  match(
    "/delayed_job",
    to: DelayedJobWeb,
    anchor: false,
    via: [:get, :post]
  )

end
