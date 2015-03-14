Rails.application.routes.draw do
  root to: 'visitors#index'

  resource :github_webhooks, only: :create, defaults: { formats: :json }
end
