Rails.application.routes.draw do
  concern(:has_contacts){ resources :contacts, except: [:index, :show] }
  concern(:has_accounts){ resources :accounts, except: [:index, :show] }
  concern(:has_credit_agreements){ resources :credit_agreements, except: [:index, :show] }
  concern(:has_pdfs){ resources :pdfs, only: [:new, :create] }

  devise_for :users, skip: [:registrations, :confirmations]

  #resources :addresses, except: :index
  resources :balances, only: :index
  resources :balances, only: :show, format: true, constraints: {format: :pdf}
  resources :creditors, controller: :addresses, type: 'Creditor'
  resources :credit_agreements, only: :index
  resources :credit_agreements, only: :show, constraints: {id: /\d+/} do
    #resources :balances, except: [:index, :show]
    resources :manual_balances, controller: :balances, type: 'ManualBalance', only: [:edit, :update, :destroy]
    resources :auto_balances, controller: :balances, type: 'AutoBalance', only: [:edit, :update]
    resources :termination_balances, controller: :balances, type: 'TerminationBalance', only: :destroy
    resources :payments, except: [:index, :show, :new]
    resources :deposits, except: [:index, :show, :new], controller: :payments, type: 'Deposit'
    resources :disburses, except: [:index, :show, :new], controller: :payments, type: 'Disburse'
  end
  resources :letters, only: :index, type: 'Letter' do
    member{ post 'create_pdfs', as: 'create_pdfs_for' }
    member{ get 'get_pdfs', as: 'get_pdfs_for' }
  end
  resources :balance_letters, controller: :letters, except: :index, type: 'BalanceLetter'
  resources :termination_letters, controller: :letters, except: :index, type: 'TerminationLetter'
  resources :standard_letters, controller: :letters, except: :index, type: 'StandardLetter'
  resources :organizations, controller: :addresses, type: 'Organization', except: :index do
    concerns :has_contacts, :has_accounts, :has_credit_agreements, :has_pdfs
  end
  resources :pdfs, only: :show, format: true, constraints: {format: :pdf}
  resources :pdfs, only: [:destroy, :update]
  resources :people, controller: :addresses, type: 'Person', except: :index do
    concerns :has_accounts, :has_credit_agreements, :has_pdfs
  end
  resources :project_addresses, controller: :addresses, type: 'ProjectAddress', except: :index do
    concerns :has_contacts, :has_accounts
  end
  resources :users
  get 'project' => 'project#show'

  authenticated :user do
    root to: 'project#show', as: :authenticated_root
  end

  get "/404", to: "errors#not_found"
  get "/422", to: "errors#change_rejected"
  get "/500", to: "errors#internal_server_error"

  root to: redirect('/users/sign_in')
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
