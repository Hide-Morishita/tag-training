# 購入機能に必要なモデル
class ItemTransaction < ApplicationRecord
  # <<アソシエーション>>
  belongs_to :user
  belongs_to :item
  has_one :address
end


