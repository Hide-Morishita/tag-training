class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: {maximum: 5}

  has_many :item_tag_relations, dependent: :destroy 
  has_many :items, through: :item_tag_relations
end
