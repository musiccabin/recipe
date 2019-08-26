Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users, only: [:new, :create] do
    resource :mealplan, only: [:show]
  end
  resource :session, only: [:new, :create, :destroy]
  resources :myrecipes do
    resources :reviews do
      resources :likes
      resources :reviews
    end
    resources :ingredients
    resources :completions, only: [:create, :destroy]
    resources :favourites, only: [:create, :destroy]
  end


  get '/', {to: 'welcome#index', as: 'root'}
  get 'welcome/index', {to: 'welcome#index'}
  get '/forgot_password', {to: 'users#forgot_password', as: 'forgot_password'}
  post '/forgot_password', {to: 'users#send_email', as: 'send_email'}
  get '/password_reset', {to: 'users#password_reset', as: 'password_reset'}
  post '/password_reset', {to: 'users#password_reset'}
  get '/setting', {to: 'users#setting', as: 'setting'}
  post '/setting', {to: 'users#update', as: 'user_update'}
  get '/favourites', {to: 'users#favourites', as:'favourites'}
  get '/completions', {to: 'users#completions', as:'completions'}
  get '/groceries', {to: 'groceries#index', as: 'groceries'}
  post '/groceries', {to: 'groceries#create'}
  post '/groceries/:id/toggle', {to: 'groceries#complete_grocery', as: 'complete_grocery'}
  # post '/myrecipe_new', {to: 'myrecipe#add_tag', as: 'add_tag'}
  patch '/myrecipes/:id/toggle', {to: 'myrecipes#hide', as:'hide_recipe'}
  get '/admin/panel', {to: 'admin#panel', as:'admin_panel'}
  get '/preferences', {to: 'users#preferences', as: 'user_preferences'}
  post '/preferences', {to: 'users#preferences'}
  delete '/preferences/:id/restriction', {to: 'users#delete_restriction', as: 'delete_restriction'}
  delete '/preferences/:id/tag', {to: 'users#delete_tag', as: 'delete_tag'}
  get '/myrecipes/:id/add_ingredients', {to: 'myrecipes#add_ingredients', as: 'add_ingredients'}
  post '/myrecipes/:id/add_ingredients', {to: 'myrecipes#add_ingredients'}
  patch '/myrecipes/:id/add_ingredients/:link_id/update', {to: 'myrecipes#update_ingredient', as: 'update_ingredient'}
  delete '/myrecipes/:id/add_ingredients/:link_id', {to: 'myrecipes#delete_ingredient', as: 'delete_ingredient'}
  post 'recommendations', {to: 'users#recommend_recipes', as: 'recipe_recommendation'}
  get '/add_leftover', {to: 'users#add_leftover', as: 'add_leftover'}
  post '/add_leftover', {to: 'users#add_leftover', as: 'save_leftover'}
  patch '/add_leftover/:id/update', {to: 'users#update_leftover', as: 'update_leftover'}
  delete '/add_leftover/:id', {to: 'users#delete_leftover', as: 'delete_leftover'}

  post '/add_to_mealplan', {to: 'welcome#add_to_mealplan', as: 'add_to_mealplan'}
  post '/remove_from_mealplan', {to: 'welcome#remove_from_mealplan', as: 'remove_from_mealplan'}



  match(
    "/delayed_job",
    to: DelayedJobWeb,
    anchor: false,
    via: [:get, :post]
  )

end
