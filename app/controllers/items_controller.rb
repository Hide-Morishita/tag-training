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
    form = [@item, @item.tags[0]]
    @item_form = ItemForm.new(form)
    # binding.pry
    return redirect_to root_path if current_user.id != @item.user.id
    end
    
    def update
       @item.update(item_params) if current_user.id == @item.user.id
       return redirect_to item_path if @item.valid?
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
