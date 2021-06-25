Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :saml do
    collection do
      get :init
      post :consume
      get :metadata
    end
  end
end
