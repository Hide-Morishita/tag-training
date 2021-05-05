class ItemsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :select_item, except: [:index, :new, :create, :tag_search]
  
  def index
    @items = Item.all.order(created_at: :desc)
  end

  def new
    @item_form = ItemForm.new
  end

  def create
    @item_form = ItemForm.new(item_params)
    @item_form.price_int
    #binding.pry
    if @item_form.valid?
      @item_form.save
      return redirect_to root_path
    end
    render 'new'
  end

  def show
  end


  def edit
    #オブジェクトの情報をハッシュ形式に変更する、引数として持たせるため
    item_attributes = @item.attributes
    @item_form = ItemForm.new(item_attributes)
    @item_form.tag_name = @item.tags[0].name if @item.tags[0].present?
    @item_form.image = @item.image.blob
    return redirect_to root_path if current_user.id != @item.user.id
  end
  
  def update
    @item_form = ItemForm.new(item_params)
    @item_form.price_int
    @item_form.image = @item.image.blob
    # binding.pry
    if @item.tags[0].present?
      if @item_form.tag_name.present?
        tag = Tag.where(name: @item_form.tag_name).first_or_initialize
        if tag.id.present?
          @item_tag = ItemTagRelation.find(tag.id) 
        end
      end
    end
    if @item_form.valid?
      # updateメソッドの呼び出し
      # 引数(formの内容、編集する商品の情報、編集する商品に紐づく中間テーブルの情報)
      @item_form.update(item_params, @item, @item_tag)
      return redirect_to item_path(@item)
    end
    render 'edit'
  end

  def destroy
    @item.destroy if current_user.id == @item.user.id
    redirect_to root_path
  end

  def tag_search
    # searchアクションと区別する
    # 空の入力があった場合、空の配列を返す
    return render json: {keyword: []} if params[:tag_name] == ""
    # return nil if params[:tag_name] == ""
    tag = Tag.where(['name LIKE ?', "%#{params[:tag_name]}%"] )
    render json:{ keyword: tag}
  end

  private
  def item_params
    params.require(:item_form).permit(
      :image,
      :name,
      :info,
      :category_id,
      :sales_status_id,
      :shipping_fee_status_id,
      :prefecture_id,
      :sceduled_delivery_id,
      :price,
      :tag_name
    ).merge(user_id: current_user.id)
  end

  def select_item
    @item = Item.find(params[:id])
  end

end
