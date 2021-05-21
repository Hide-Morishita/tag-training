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

#### 2-1.editでフォームオブジェクトのインスタンスを生成するときに注意が必要

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

3日で終わる追加実装にもこちらの内容が記述されていますので確認してみましょう。

実際にattributesメソッドを使用してみます。

<img width="432" alt="スクリーンショット 2021-05-15 16 28 21" src="https://user-images.githubusercontent.com/64821613/118352387-224e1400-b59c-11eb-94be-302e0ea53d14.png">


attributesメソッドを使用したことにより、先程のオブジェクトの情報が配列に置き換わっているのがわかるかと思います。

こちらを実際のeditアクション内に記述し、編集ページに遷移できるか確認してみましょう。

controllers/items_controller.rb

<img width="534" alt="スクリーンショット 2021-05-20 15 57 29" src="https://user-images.githubusercontent.com/64821613/118933426-25724700-b984-11eb-864b-3d199ed9f1c7.png">

<img width="1183" alt="スクリーンショット 2021-05-20 16 12 27" src="https://user-images.githubusercontent.com/64821613/118935207-3b810700-b986-11eb-8580-fe0bccba1c3a.png">

編集ページに遷移しようとしたら、今度は別のエラーが出てきました。

ItemForm(フォームオブジェクト)の不明な属性「id」があると言われています。

`@item.attributes`の中にidの情報があるもののフォームオブジェクト側ではidという属性を扱えないという現象になります(created_atとupdated_atも同様)。

こちらの原因は、フォームオブジェクト内の`attr_accessor`で受け取りの記述をしていないためになります。

`attr_accessor`に**id・created_at・update_at**を受け取る記述をします。

models/item_form.rb
```ruby
attr_accessor(
                :name, :info, :category_id, :sales_status_id,
                :shipping_fee_status_id, :prefecture_id, :sceduled_delivery_id,
                :price,
                :image,
                :user_id,
                :tag_name,
                # 編集機能実装時に以下を追加
                :id,
                :created_at,
                :updated_at
               )
```

これで編集ページに遷移することは可能になりました。

しかし、また問題が発生します。

下記のキャプチャ動画を見てみましょう。

![d644702f4ba841629038fdc671ff123d](https://user-images.githubusercontent.com/64821613/118937796-e0044880-b988-11eb-9009-d1310cc8554d.gif)

詳細ページでは、タグが表示されていたのに編集ページに遷移するとタグの入力欄が空になっていることがわかります。

なぜこのようなことが起きてしまうのでしょうか?

理由としては先程確認した、@item.attributesの中にtagの情報が含まれていないからです。

そのため、editアクション内にタグの情報を取得し、フォームオブジェクトに渡すための記述が必要になります。

どのようにタグの情報を取得するかですが、

```
①findメソッドで取得した、商品に紐づくtagの情報が存在していることを確認
②①が存在していたら、フォームオブジェクトのtag_nameに値を代入
```

上記の内容でタグの情報を取得し、フォームオブジェクトに渡していきます。

コントローラーの記述は以下のようになります。

controllers/items_controller.rb
```ruby
  def edit
    #オブジェクトの情報をハッシュ形式に変更する、引数として持たせるため
    item_attributes = @item.attributes
    @item_form = ItemForm.new(item_attributes)
    # 以下の記述を追記する
    @item_form.tag_name = @item.tags[0].name if @item.tags[0].present?
  end
```

必ずタグが付いているとは限らないため、`if @item.tags[0].present?`で商品に紐づくタグの情報があった場合のみ処理を実行するようにします。

タグの情報は、今回の実装ですと`@item.tags[0].name`または、`@item.tags.first.name`で取得することが可能です。

取得したタグの情報は、フォームオブジェクト内で扱いたいため、`@item_form.tag_name`に代入しています。

この記述をすることで問題なくタグの情報も渡せたかなと思います。

![a24105ce03f423b2dd210724b7acda69](https://user-images.githubusercontent.com/64821613/118968535-ff11d300-b9a6-11eb-9828-02dd54a4448f.gif)

編集ページに遷移することが可能になりました。

次に編集機能でバリデーションを通過できるか確認していきたいと思います。

createアクション同様にpriceを数値に変えておきましょう。

controllers/items_controller.rb
```ruby
  def update
    @item_form = ItemForm.new(item_params)
    @item_form.price_int # priceを数値に変更するためのメソッドの呼び出し

    if @item_form.valid?
      # バリデーションを通過するか確認する
      binding.pry 
      return redirect_to item_path(@item)
    end
    render 'edit'
  end
```

正常にバリデーションを通過したら、binding.pryで処理が止まります。

変更するボタンを押してみましょう。

処理が止まらず、バリデーションのエラーメッセージが出てきてしまいました。

<img width="594" alt="スクリーンショット 2021-05-20 20 11 28" src="https://user-images.githubusercontent.com/64821613/118969110-a68f0580-b9a7-11eb-9ca3-6064e408a234.png">

imageが空だと言われています。

どうやらフォームオブジェクトに画像の情報がうまく渡せていないようです。

そのためtag同様、imageの情報も取得する必要がありそうです。

editアクション内に`binding.pry`を記述し、ターミナルで情報が取得できるか確認してみましょう。

controllers/items_controller.rb
```ruby
  def edit
    item_attributes = @item.attributes
    @item_form = ItemForm.new(item_attributes)
    @item_form.tag_name = @item.tags[0].name if @item.tags[0].present?
    # 処理を止めてフォームオブジェクトに画像の情報が渡せているか確認する
    binding.pry
  end
```

ターミナルで確認してみます。

`@item_form`の中身を見てみましょう。

<img width="462" alt="スクリーンショット 2021-05-20 20 36 13" src="https://user-images.githubusercontent.com/64821613/118972183-3b473280-b9ab-11eb-9836-6b2e393621d4.png">

imageはなさそうですね。

念の為、`@item_form.image`で画像の情報が取得できるか確認してみましょう。

<img width="366" alt="スクリーンショット 2021-05-20 20 36 35" src="https://user-images.githubusercontent.com/64821613/118972543-9ed16000-b9ab-11eb-9316-e185f73379b3.png">

やはり画像の情報は、フォームオブジェクト内に無いようですね。

imageはActiveStorageを使用していますので、以下のように記述することで情報を取得することが可能になります。

```ruby
@item.image.blob
```

<img width="715" alt="スクリーンショット 2021-05-20 20 37 06" src="https://user-images.githubusercontent.com/64821613/118972826-f374db00-b9ab-11eb-95ba-cf08a6f28466.png">

ターミナルに打ち込んでみると、画像の情報が取得できていることが確認できるかと思います。

では、取得したをフォームオブジェクトに渡していきましょう。

edit、updateアクションを以下のように記述していきます。

```ruby
  def edit
    item_attributes = @item.attributes
    @item_form = ItemForm.new(item_attributes)
    @item_form.tag_name = @item.tags[0].name if @item.tags[0].present?
    # 商品に紐付いた画像の情報をフォームオブジェクトに渡す
    @item_form.image = @item.image.blob
  end
  
  def update
    @item_form = ItemForm.new(item_params)
    @item_form.price_int
    # 商品に紐付いた画像の情報をフォームオブジェクトに渡す
    @item_form.image = @item.image.blob

    if @item_form.valid?
      binding.pry 
      return redirect_to item_path(@item)
    end
    render 'edit'
  end
```

これでバリデーションチェック後に処理が止まるかと思います。

やっとupdateの処理に進むことができそうです。

#### 2-*.updateの処理を記述

updateメソッドは、saveメソッド同様にフォームオブジェクト内に記述してコントローラー側で呼び出します。

updateの処理では、様々なパターンが考えられます。

<img width="1033" alt="スクリーンショット 2021-05-20 21 16 13" src="https://user-images.githubusercontent.com/64821613/118977138-cd056e80-b9b0-11eb-800b-50c200b017ae.png">

編集機能が難しいのは、これらのパターンをクリアする必要があるからだと思っています。

まずは、フォームオブジェクト内にupdateメソッドの定義をしていきます。

今回のポイントとしては、updateメソッドを呼び出す際に引数を3つ渡していることです。

```ruby
# コントローラー側
@item_form.update(item_params, @item, @item_tag)

# フォームオブジェクト側
def update(params, item, item_tag)
  # 省略
end
```

- 第一引数・・・編集ページから送られてきた商品の情報
- 第二引数・・・編集を行う商品
- 第三引数・・・中間テーブルの情報

まずはコントローラーの記述を見ていきます。

```ruby
  def update
    @item_form = ItemForm.new(item_params)
    @item_form.price_int # priceをinteger型に変更
    @item_form.image = @item.image.blob

    # ①
    if @item.tags[0].present? && @item_form.tag_name.present?
      tag = Tag.where(name: @item_form.tag_name).first_or_initialize
      # ②
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
  
  ①では、「商品に紐付いたタグの情報"かつ"フォームオブジェクトにタグの情報があるか」を確認しています。
  
  → ①の条件が通らなかった場合は、タグの情報が空であることがわかります。
  
  ②では、①の条件を満たしている場合(タグの情報があった場合)、そのタグに紐づく中間テーブルの情報があるか確認しています。
  
  → find_byで情報を取得しているのは、中間テーブルのtag_id(外部キー)とtag.id(タグテーブルの主キー)が一致しているか確認するためです。
    findの場合は、id(中間テーブルの主キー)しか検索できないため使用していません。
  

次にフォームオブジェクトの記述内容を見ていきましょう。

models/item_form.rb
```ruby
  def update(params, item, item_tag)
    # ①
    params.delete(:tag_name)
    # ②
    item.update(params)

    ## 同じタグが作成されることを防ぐため、first_or_initializeで既に存在しているかチェックする
    tag = Tag.where(name: tag_name).first_or_initialize

    if tag_name.present?
      tag.save
    end
    
    # ③
    if tag_name.blank? && item_tag.blank?
      # デフォルトでは、has_many :throughの関連付けの場合はdelete_allが渡されている
      item.item_tag_relations.delete_all
      return
    end

    # ④
    if item.item_tag_relations.blank?
      item.item_tag_relations.create(tag_id: tag.id, item_id: item.id)
    end
    
    # ⑤
    if item_tag.present?
      item_tag.update(tag_id: tag.id, item_id: item.id)
    else
      item.item_tag_relations.update(tag_id: tag.id, item_id: item.id)
    end
    
  end
```

①では、params(第一引数)からtag_nameを削除しておきます。

→ itemテーブルにはtag_nameが存在しないため、商品にの情報を編集しようとするとエラーが発生してしまいます。
  商品の情報、タグ、中間テーブルの情報は別々に編集、保存していきます。
    
ちなみにこのようなエラーが発生します。

<img width="1179" alt="スクリーンショット 2021-05-20 21 27 03" src="https://user-images.githubusercontent.com/64821613/119115209-e0bcdd80-ba61-11eb-8305-d10276bacbcb.png">

②では、第二引数(編集を行う商品)の情報を編集しています。

③では、「フォームオブジェクトに空のタグ情報が送られてきたとき"かつ"コントローラーから送られてきた中間テーブルの情報が空の場合」の処理を記述しています。

→ こちらは付いていたタグを外すために必要になります。
タグを外した場合、それ以上の処理は必要ないため、`return`を使ってコントローラー側に処理を返しています。

④では、③に当てはまらない場合で「商品に紐付いた中間テーブルの情報が空の場合」の処理になります。

→ 商品に紐付いた中間テーブルの情報を保存しています。

⑤では、「コントローラーから送られてきた中間テーブルの情報が、空ではなかった場合」と「空の場合」の処理をしています。

→ 「空ではなかった場合」は、引数で送られてきた中間テーブルの情報を編集します。

→ 「空の場合」は、商品に紐づく中間テーブルの情報を編集します。
  
編集機能は難易度が高く難しい実装にはなりますが、カリキュラムの内容で学んできた内容+@で実装することも可能です。

実装の参考になれば幸いです。

### 編集機能完成コード

controllers/items_controller.rb

```ruby
  def edit
    item_attributes = @item.attributes
    @item_form = ItemForm.new(item_attributes)
    @item_form.tag_name = @item.tags[0].name if @item.tags[0].present?
    @item_form.image = @item.image.blob
  end
  
  def update
    @item_form = ItemForm.new(item_params)
    @item_form.price_int
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

models/item_form.rb

```ruby
  def update(params, item, item_tag)
    params.delete(:tag_name)
    item.update(params)

    tag = Tag.where(name: tag_name).first_or_initialize
    if tag_name.present?
      tag.save
    end
    
    if tag_name.blank? && item_tag.blank?
      item.item_tag_relations.delete_all
      return
    end

    if item.item_tag_relations.blank?
      item.item_tag_relations.create(tag_id: tag.id, item_id: item.id)
    end
    
    if item_tag.present?
      item_tag.update(tag_id: tag.id, item_id: item.id)
    else
      item.item_tag_relations.update(tag_id: tag.id, item_id: item.id)
    end
    
  end
```
