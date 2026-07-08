Rails.application.routes.draw do
  root 'pages#room'
  get 'room', to: 'pages#room'
end
