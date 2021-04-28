class Item < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :category
  belongs_to_active_hash :sales_status
  belongs_to_active_hash :shipping_fee_status
  belongs_to_active_hash :prefecture
  belongs_to_active_hash :sceduled_delivery
  has_one_attached :image
  belongs_to :user
  has_one :item_transaction
  # 親にhas_one子にbelongs_toを記述してアソシエーションを組む

   # <<バリデーション>>

  # 値が入っているか検証
  with_options presence: true do
    validates :image
    validates :name
    validates :info
    validates :price
  end

  # 金額が半角であるか検証
  validates :price, numericality: { with: /\A[0-9]+\z/, message: 'Half-width number' }

  # 金額の範囲
  validates_inclusion_of :price, in: 300..9_999_999, message: 'Out of setting range'
  # validates numericality: {only_integer: true, greater_than_or_equal_to:300,less_than_or_equal_to:999999}

  # 選択関係で「---」のままになっていないか検証
  with_options numericality: { other_than: 0, message: 'Select' } do
    validates :category_id
    validates :sales_status_id
    validates :shipping_fee_status_id
    validates :prefecture_id
    validates :sceduled_delivery_id
  end
end