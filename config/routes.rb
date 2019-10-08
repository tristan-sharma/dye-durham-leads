Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new'
  end

root to: 'matches#index'


post 'update_match_status', action: :update_status, controller: 'matches'
post 'mark_link_viewed', action: :mark_link_viewed, controller: 'matches'

end
