Rails.application.routes.draw do
  resources :invoices
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root :to => redirect('/invoices')

  post '/presigned_url', to: 'direct_upload#create'

end
