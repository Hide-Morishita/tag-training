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
                # item_attributes = @item.attributesでハッシュ形式に切り替えている
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

  # タグのバリデーション
  validates :tag_name, length: {maximum: 5}

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
    if tag_name.present?
      tag.save
    end

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

    if tag_name.present?
      tag.save
    end
    
    # フォームオブジェクトに空のタグ情報が送られてきたとき"かつ"コントローラーから送られてきた中間テーブルの情報が空の場合の処理
    if tag_name.blank? && item_tag.blank?
      # 商品に紐づく中間テーブルの情報を削除する
      # デフォルトでは、has_many :throughの関連付けの場合はdelete_allが渡されている
      item.item_tag_relations.delete_all
      return
    end

    # 商品に紐付いた中間テーブルの情報が空の場合
    if item.item_tag_relations.blank?
      # 商品に紐付く中間テーブルに情報を保存する
      item.item_tag_relations.create(tag_id: tag.id, item_id: item.id)
    end
    
    # コントローラーから送られてきた中間テーブルの情報が、空ではなかったときの処理
    if item_tag.present?
      item_tag.update(tag_id: tag.id, item_id: item.id)
    else
      item.item_tag_relations.update(tag_id: tag.id, item_id: item.id)
    end
    

  end


end
