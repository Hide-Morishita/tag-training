FactoryBot.define do
  factory :pay_form do
    token { 'sampletokensampletoken' }
    postal_code { '123-4567' }
    prefecture { 1 }
    city { '東京都' }
    addresses { '1-1' }
    phone_number { '09012345678' }
    # association :user
    # association :item
    # フォームオブジェクトだからアソシエーション組めない
  
  end
end