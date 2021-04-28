Rails.application.routes.draw do
  # get 'transactions/index'
  devise_for :users
  root to: "items#index"
  resources :items do
    resources :transactions, only: [:index, :new, :create]
    # 購入機能は商品情報にネストされる。
  end
end
