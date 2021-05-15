# タグ付け

## 参考資料

- カリキュラム

- ３日で終わる追加実装

## タグ付け実装時のポイント

### 1.priceを数値として読み込ませる(create、update共通)

なぜ数値として読み込ませる必要があるのか？

**結論： バリデーションで弾かれてしまうから**

priceはinteger型で実装しているため、値は数値でなくてはいけません。

paramsで送られてくる値は、"1234"のように文字列になっていますが、通常のモデルであればinteger型であると判断し数値として扱ってくれます。

しかしフォームオブジェクトの場合はそれができず、文字列のまま処理されてしまいます。

そのため、priceにかけられている、半角数値を許可するバリデーション(numericality)で毎回弾かれてしまいます。

この問題を解消するため、フォームオブジェクト内にpriceを数値に変えるためのメソッドを定義し、コントローラーで呼び出しています。

定義したメソッドは以下になります。

models/item_form.rb
```ruby 
  def price_int
    @price = price.to_i  # attr_accessorで受け取った値を、to_iメソッドを使用して数値に変更する。
  end
```

バリデーションチェックをするために必要な記述になりますので、出品(create)と編集(update)両方で呼び出す必要があります。

controllers/items_controller.rb
```ruby
  def create
    @item_form = ItemForm.new(item_params)
    @item_form.price_int # メソッドの呼び出し
    if @item_form.valid?
      @item_form.save
      return redirect_to root_path
    end
    render 'new'
  end
  
  # 省略
  
  def update
    @item_form = ItemForm.new(item_params)
    @item_form.price_int # メソッドの呼び出し
    @item_form.image = @item.image.blob

    if @item.tags[0].present? && @item_form.tag_name.present?
      tag = Tag.where(name: @item_form.tag_name).first_or_initialize
      if tag.item_tag_relations.present?
        @item_tag = ItemTagRelation.find_by(tag_id: tag.id) 
      end
    end

    if @item_form.valid?
      @item_form.update(item_params, @item, @item_tag)
      return redirect_to item_path(@item)
    end
    render 'edit'
  end
```

3日で終わる追加実装では、ActiveModel::Attributesを使用していますが、

こちらは、attr_accessorと違い受け取る値の型を指定することができます。

出品機能に関しては、上記で記述した内容に気をつけていれば、あとは、カリキュラムの内容で実装が可能です。

### 2.編集機能

編集機能に関しては、難易度が激むずになります。

編集機能で抑えるポイントを記述していきます。

#### 1.editでフォームオブジェクトのインスタンスを生成するときに注意が必要

編集ページ(edit.html.erb)のform_withに、modelを持たせるために

コントローラー内のeditアクションにて

フォームオブジェクトのインスタンスを生成する必要がありますが、この際に注意が必要です。

編集なので、商品の情報を持たせる必要がありますが、findメソッドで呼び出した商品の情報をそのまま使用することができません。

before_actionなどで呼び出している以下の記述がそのまま使用できないということになります。

```ruby
  @item = Item.find(params[:id])
```

editアクションにて以下の記述にした際にエラーが発生します。

```ruby
  def edit
    @item_form = ItemForm.new(@item)
    # 省略
  end
```

<img width="1439" alt="スクリーンショット 2021-05-15 16 22 37" src="https://user-images.githubusercontent.com/64821613/118351988-f03bb280-b599-11eb-9be7-b6bbc698f675.png">

内容としては、引数にはハッシュの情報を渡してほしいとのこと

editアクション内に`binding.pry`を入れて@itemの情報を確認してみます。

<img width="546" alt="スクリーンショット 2021-05-15 16 27 49" src="https://user-images.githubusercontent.com/64821613/118352382-1c583300-b59c-11eb-955f-d432b476df29.png">

情報は取得できていますが、あくまでオブジェクトの属性であって、ハッシュ形式ではなさそうです。

では、取得したオブジェクトの情報をハッシュ形式にするにはどうしたらいいのか？

そこで使うのが、`attributesメソッド`です。

これは、オブジェクトの属性値をハッシュで取得してくれるメソッドになります。

3日で終わる追加実装にもこちらの内容が記述されていますので確認してみるといいかもしれません。

<img width="432" alt="スクリーンショット 2021-05-15 16 28 21" src="https://user-images.githubusercontent.com/64821613/118352387-224e1400-b59c-11eb-94be-302e0ea53d14.png">




