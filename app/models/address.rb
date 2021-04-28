# 住所情報登録に必要なモデル（Orderモデルで記載多い）
class Address < ApplicationRecord
  # <<アソシエーション>>
  belongs_to :item_transaction
end
