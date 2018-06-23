Rails.application.routes.draw do
  root 'home#index'
  post '/download/:type', to: 'home#download_forecast', as: :download,
    type: /csv|json/
end
