# タグ付け

## 参考資料

- カリキュラム
https://master.tech-camp.in/v2/curriculums/4996

- ３日で終わる追加実装
https://qiita.com/rabi0102/private/d389c58fe7913265dcc7

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


### 2.編集機能

出品機能に関しては、**1**で記述した内容に気をつけていれば、あとは、カリキュラムの内容で実装が可能です。

編集機能に関しては、難易度が激むずになります。

編集機能で抑えるポイントを記述していきます。

#### 1.editでフォームオブジェクトのインスタンスを生成するときに注意が必要

編集ページ(edit.html.erb)のform_withに、modelを持たせるためにコントローラー内のeditアクションにて

フォームオブジェクトのインスタンスを生成する必要がありますが、この際に注意が必要です。






