Rails.application.routes.draw do
  get "download_pdf/:warehouse_id", to: "items#download_pdf", as: "download_pdf"
  get "preview_pdf/:warehouse_id", to: "items#preview_pdf", as: "preview_pdf"
  devise_for :users, controllers: { registrations: 'users/registrations' }
  root to: 'pages#home'
  resources :users_admin, controller: 'users' do
    collection do
      post '/search_users', to: 'users#search_users', as: :search_users
    end
    resources :access_alloweds, only: %i[create new destroy] do
      collection do
        post '/search_warehouse', to: 'access_alloweds#search_warehouse', as: :search_warehouse
      end
    end
  end
  resources :pos_sessions do
    get '/transaktions/:id/annullated', to: 'transaktions#annullated', as: 'transaktion_annullated'
    get '/transaktions/:id/paying', to: 'transaktions#paying', as: 'transaktion_paying'
    resources :transaktions, only: %i[index create edit update destroy show] do
      collection do
        delete '/delete/:id', to: 'search_transaktions#delete_session', as: :delete
        delete '/delete_all', to: 'search_transaktions#delete_all_session', as: :delete_all
        post '/search', to: 'search_transaktions#search_product_purchase', as: :search
        post '/search_transaktions', to: 'search_transaktions#search_transaktions', as: :search_transaktions
        post '/search_sale', to: 'search_transaktions#search_product_sale', as: :search_sale
        post '/search_market', to: 'search_transaktions#search_market_rates', as: :search_market
        post '/search_provider', to: 'search_transaktions#search_provider', as: :search_provider
        post '/search_warehouse', to: 'search_transaktions#search_warehouse', as: :search_warehouse
        post '/create_sale', to: 'search_transaktions#create_sales_with_customer', as: :create_sale
        post '/create_transfer', to: 'search_transaktions#create_item_transfer', as: :create_transfer
        post '/item_transactions', to: 'search_transaktions#item_transactions_session', as: :item_transactions
      end
    end

    collection do
      post '/search_pos_sessions', to: 'pos_sessions#search_pos_sessions', as: :search_pos_sessions
    end

    get '/sales', to: 'transaktions#sales'
    get '/purchases', to: 'transaktions#purchases'
    get '/market_rates', to: 'transaktions#market_rates'
    get '/item_transfer', to: 'transaktions#item_transfer'
    get '/modal_create_product', to: 'search_transaktions#modal_create_product'
    get '/modal_confirm_market_rates', to: 'search_transaktions#modal_confirm_market_rates'
    get '/modal_confirm_transfer', to: 'search_transaktions#modal_confirm_transfer'
  end

  get '/payment_center', to: 'transaktions#payment_center'

  resources :providers do
    collection do
      get '/modal_new', to: 'providers#modal_new'
      post '/searches', to: 'providers#searches'
      post '/search', to: 'providers#search'
    end
  end

  resources :buyers do
    collection do
      post '/searches', to: 'buyers#searches'
      post '/search', to: 'buyers#search'
    end
  end

  resources :orders, only: :index

  resources :products do
    collection do
      post '/search_products', to: 'products#search_products', as: :search_products
      post '/search_providers', to: 'products#search_providers', as: :search_providers
    end
  end
  resources :accounts, only: %i[create show edit update destroy]
  resources :warehouses do
    collection do
      post '/search_warehouses', to: 'warehouses#search_warehouses', as: :search_warehouses
    end
    resources :warehouse_details, only: %i[create update]
    resources :items do
      collection do
        post '/search_product', to: 'items#search_product', as: :search_product
        post '/search_items', to: 'items#search_items', as: :search_items
      end
    end
  end
end

# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
# Defines the root path route ("/")
