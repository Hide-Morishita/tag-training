class ItemForm
  include ActiveModel::Model
  ## ItemFormクラスのオブジェクトがitemモデルの属性を扱えるようにする
  attr_accessor(
                :name, :info, :category_id, :sales_status_id,
                :shipping_fee_status_id, :prefecture_id, :sceduled_delivery_id,
                :price,
                :image,
                :user_id,
                :tag_name,
                # 編集機能で必要
                :id,
                :created_at,
                :updated_at
               )
  # :tag_nameにしているのは、itemの:nameと区別するため
  # <<バリデーション（ほぼitem.rbの流用）>>
  
  def price_int
   @price = price.to_i
  end

  # 値が入っているか検証
  with_options presence: true do
    validates :image
    validates :name
    validates :info
    validates :price

  end

  with_options numericality: { other_than: 0, message: 'Select' } do
    validates :category_id
    validates :sales_status_id
    validates :shipping_fee_status_id
    validates :prefecture_id
    validates :sceduled_delivery_id
  end

  # 金額が半角であるか検証
  validates :price, numericality: { message: 'Half-width number' }

  # 金額の範囲
  validates_inclusion_of :price, in: 300..9_999_999, message: 'Out of setting range'

  def save
    item = Item.create(
      name: name,
      info: info,
      price: price,
      category_id: category_id,
      sales_status_id: sales_status_id,
      shipping_fee_status_id: shipping_fee_status_id,
      prefecture_id: prefecture_id,
      sceduled_delivery_id: sceduled_delivery_id,
      user_id: user_id,
      image: image)

    ## 同じタグが作成されることを防ぐため、first_or_initializeで既に存在しているかチェックする
    tag = Tag.where(name: tag_name).first_or_initialize
    tag.save

    ItemTagRelation.create(tag_id: tag.id, item_id: item.id)

  end

  def update(params, item, item_tag)
    # params(hash)からtag_nameを削除しておく。itemテーブルにはtag_nameが存在しないため
    params.delete(:tag_name)
    # 編集した商品だけ更新する
    item.update(params)
    # Item.update(params)にしてしまうと、itemテーブル全ての商品が更新されてしまう


    ## 同じタグが作成されることを防ぐため、first_or_initializeで既に存在しているかチェックする
    tag = Tag.where(name: tag_name).first_or_initialize
    tag.save
    
    # binding.pry
    # 該当する商品に紐づく情報だけ更新する
    item_tag.update(tag_id: tag.id, item_id: item.id)
    # ItemTagRelation.update(tag_id: tag.id, item_id: item.id)
    # 上記の記述にしてしまうと、中間テーブル全ての情報が更新されてしまう

  end


end
