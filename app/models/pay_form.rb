class PayForm
  include ActiveModel::Model
  # この記述がなかったらrender、form_with、validationの機能が使えない
  attr_accessor :item_id, :token, :postal_code, :prefecture, :city, :addresses, :building, :phone_number, :user_id
  # Rubyの機能、setter（外部からのインスタンス変数に値をセットする）とgetter(外部からのインスタンス変数の値を取得する)からなる。保存したい複数のテーブルのカラム名をすべて使えるようにする


  # <<バリデーション>>
  with_options presence: true do
    validates :item_id
    validates :token, presence: { message: "can't be blank" }
    validates :postal_code, format: { with: /\A\d{3}[-]\d{4}\z/, message: 'Input correctly' }
    validates :prefecture, numericality: { other_than: 0, message: 'Select' }
    validates :city
    validates :addresses
    validates :phone_number
    validates :user_id
  end

  validates :phone_number, length: { maximum: 11, message: 'Too long' }
  validates :phone_number, numericality: {message: 'Input only number'}

  # 各テーブルにデータを保存する処理を書く
  def save
    item_transaction = ItemTransaction.create(
                          item_id: item_id,
                          user_id: user_id
                        )
    Address.create(
      item_transaction_id: item_transaction.id,
      postal_code: postal_code,
      prefecture: prefecture,
      city: city,
      addresses: addresses,
      building: building,
      phone_number: phone_number
    )
  end
end
