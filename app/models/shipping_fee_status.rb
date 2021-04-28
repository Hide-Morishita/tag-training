class ShippingFeeStatus < ActiveHash::Base
  self.data = [
    { id: 0, fee: '---' },
    { id: 1, fee: '着払い(購入者負担)' },
    { id: 2, fee: '送料込み(出品者負担)' }
  ]
end