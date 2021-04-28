FactoryBot.define do
  factory :item_transaction do
    association :user
    association :item
  end
end