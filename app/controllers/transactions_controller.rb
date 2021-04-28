# 購入のコントローラー

class TransactionsController < ApplicationController
  before_action :select_item, only: [:index, :create]
  # これがあるからcreateでindexに戻っても@item.image等の情報が表示される。これ書かないならcreateに    @item = Item.find(params[:item_id])が必要
  before_action :authenticate_user!, only: [:index]
  # devise入れてたら使える。ログインしてなかったらログイン画面に遷移させる

  def index
    return redirect_to root_path if current_user.id == select_item.user_id || select_item.item_transaction != nil

    @item_transaction = PayForm.new
  end
  # ここを通って購入画面に進む

  def create
    # binding.pry
    @item_transaction = PayForm.new(item_transaction_params)
    if @item_transaction.valid?
      pay_item
      @item_transaction.save
      return redirect_to root_path
    end
    render 'index'
  end

  private

  def select_item
    @item = Item.find(params[:item_id])
  end

  def item_transaction_params
    params.require(:pay_form).permit(
      :postal_code,
      :prefecture,
      :city,
      :addresses,
      :building,
      :phone_number
    ).merge(user_id: current_user.id, item_id: params[:item_id], token: params[:token])
  end

  def pay_item
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    Payjp::Charge.create(
      amount: @item.price,
      card: item_transaction_params[:token],
      currency: 'jpy'
    )
  end
end
