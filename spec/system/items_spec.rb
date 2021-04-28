require 'rails_helper'

RSpec.describe '商品出品', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @item = FactoryBot.build(:item)
  end
  context '商品出品ができるとき' do 
    it '有効な情報を入力すると、レコードが1つ増え、トップページへ遷移すること' do
      # ログインする
      visit new_user_session_path
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 出品ページへのリンクがある
      expect(page).to have_content('出品する')
      # 出品ページへのリンクをクリックする
      visit new_item_path
      # フォームに情報を入力する
      page.attach_file('item[image]', "#{Rails.root}/spec/fixtures/sample.png")
      fill_in 'item[name]', with: @item.name
      fill_in 'item[info]', with: @item.info
      select "レディース", from: "item[category_id]"
      select "新品、未使用", from: "item[sales_status_id]"
      select "着払い(購入者負担)", from: "item[shipping_fee_status_id]"
      select "北海道", from: "item[prefecture_id]"
      select "1~2日で発送", from: "item[sceduled_delivery_id]"
      fill_in 'item[price]', with: @item.price
      # 出品ボタンを押すとアイテムモデルのカウントが1上がる
      expect{
        find('input[name="commit"]').click
      }.to change { Item.count }.by(1)
      # トップページへ遷移する
      expect(page).to have_current_path(root_path)
    end
  end
  context '商品出品ができないとき' do 
    it '無効な情報で商品出品を行うと、商品出品ページにて、エラーメッセージ が表示されること' do
      # ログインする
      visit new_user_session_path
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 出品ページへのリンクがある
      expect(page).to have_content('出品する')
      # 出品ページへのリンクをクリックする
      visit new_item_path
      # フォームに情報を入力する
      fill_in 'item[name]', with: ""
      fill_in 'item[info]', with: ""
      fill_in 'item[price]', with: ""
      # 出品ボタンを押してもアイテムモデルのカウントは上がらない
      expect{
        find('input[name="commit"]').click
      }.to change { Item.count }.by(0)
      # 出品ページへ戻される
      expect(page).to have_content("商品の情報を入力")
      # エラーメッセージのクラスが出現する
      expect(page).to have_css "div.error-alert" 
    end
    it 'ログインしていない状態で商品出品ページへアクセスすると、ログインページへ遷移すること' do
      visit root_path
      # 出品ページへのリンクがある
      expect(page).to have_content('出品する')
      # 出品ページへのリンクをクリックする
      visit new_item_path
      # ログイン画面へ遷移する
      expect(current_path).to eq new_user_session_path
      # エラーメッセージが出現している
      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end
end

RSpec.describe '商品編集', type: :system do
  before do
    @item1 = FactoryBot.create(:item, :image)
    @item2 = FactoryBot.create(:item, :image)
  end
  context '商品編集ができるとき' do
    it '有効な情報で商品編集を行うと、レコードが更新され、商品詳細ページへ遷移し、商品出品時に入力した値が表示されていること' do
      visit new_user_session_path
      fill_in 'user[email]', with: @item1.user.email
      fill_in 'user[password]', with: @item1.user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 表示されている商品をクリック
      find(:xpath, "//a[@href='/items/#{@item1.id}']").click
      # アイテム1に「商品の編集」ボタンがある
      expect(page).to have_link '商品の編集', href: edit_item_path(@item1)
      # 編集ページへ遷移する
      visit edit_item_path(@item1)
      # すでに投稿済みの内容がフォームに入っている(画像以外)
      expect(
        find('#item-name').value
      ).to eq @item1.name
      expect(
        find('#item-info').value
      ).to eq @item1.info
      expect(
        find('#item-category').value
      ).to eq "#{@item1.category_id}"
      expect(
        find('#item-sales-status').value
      ).to eq "#{@item1.sales_status_id}"
      expect(
        find('#item-shipping-fee-status').value
      ).to eq "#{@item1.shipping_fee_status_id}"
      expect(
        find('#item-prefecture').value
      ).to eq "#{@item1.prefecture_id}"
      expect(
        find('#item-scheduled-delivery').value
      ).to eq "#{@item1.sceduled_delivery_id}"
      expect(
        find('#item-price').value
      ).to eq "#{@item1.price}"
      # 投稿内容を編集する
      page.attach_file('item[image]',"#{Rails.root}/spec/fixtures/sample2.png")
      fill_in 'item[name]', with: "#{@item1.name}+編集したテキスト"
      # 編集してもItemモデルのカウントは変わらない
      expect{
        find('input[name="commit"]').click
      }.to change { Item.count }.by(0)
      # 「商品の編集」の文字がある
      expect(page).to have_content('商品の編集')
      # トップページに遷移する
      visit root_path
      # トップページには先ほど変更した内容のツイートが存在する（画像）
      expect(page).to have_selector("img[src$='sample2.png']")
      # トップページには先ほど変更した内容のツイートが存在する（テキスト）
      expect(page).to have_content("#{@item1.name}+編集したテキスト")
    end
  end
  context '商品編集ができないとき' do
    it '無効な情報で商品編集を行うと、商品編集ページにて、エラーメッセージ が表示されること' do
      visit new_user_session_path
      fill_in 'user[email]', with: @item1.user.email
      fill_in 'user[password]', with: @item1.user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 表示されている商品をクリック
      find(:xpath, "//a[@href='/items/#{@item1.id}']").click
      # アイテム1に「商品の編集」ボタンがある
      expect(page).to have_link '商品の編集', href: edit_item_path(@item1)
      # 編集ページへ遷移する
      visit edit_item_path(@item1)
      # すでに投稿済みの内容がフォームに入っている(画像以外)
      expect(
        find('#item-name').value
      ).to eq @item1.name
      expect(
        find('#item-info').value
      ).to eq @item1.info
      expect(
        find('#item-category').value
      ).to eq "#{@item1.category_id}"
      expect(
        find('#item-sales-status').value
      ).to eq "#{@item1.sales_status_id}"
      expect(
        find('#item-shipping-fee-status').value
      ).to eq "#{@item1.shipping_fee_status_id}"
      expect(
        find('#item-prefecture').value
      ).to eq "#{@item1.prefecture_id}"
      expect(
        find('#item-scheduled-delivery').value
      ).to eq "#{@item1.sceduled_delivery_id}"
      expect(
        find('#item-price').value
      ).to eq "#{@item1.price}"
      # 投稿内容を編集する
      fill_in 'item[name]', with: ""
      # 編集してもItemモデルのカウントは変わらない
      expect{
        find('input[name="commit"]').click
      }.to change { Item.count }.by(0)
      # 編集ページへ戻される
      expect(page).to have_content('商品の情報を入力')
      # エラーメッセージのクラスが出現する
      expect(page).to have_css "div.error-alert" 
    end
    it 'ログインしていない状態で商品編集ページへアクセスすると、ログインページへ遷移すること' do
      # ログインせずにURLを直打ち
      visit edit_item_path(@item1)
      # ログイン画面へ遷移する
      expect(current_path).to eq new_user_session_path
      # エラーメッセージが出現している
      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
    it '自身の出品した商品以外の商品編集ページへアクセスすると、トップページへ遷移すること' do
      visit new_user_session_path
      fill_in 'user[email]', with: @item1.user.email
      fill_in 'user[password]', with: @item1.user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      find(:xpath, "//a[@href='/items/#{@item2.id}']").click
      # アイテム2に「購入画面に進む」ボタンがある
      expect(page).to have_link '購入画面に進む', href: item_transactions_path(@item2)
      # アイテム2に「商品の編集」の文字はない
      expect(page).to have_no_content '商品の編集'
      # 他人の出品した商品編集ページのURLを直打ち
      visit edit_item_path(@item2)
      # トップページへ戻される
      visit root_path
    end
  end
end

RSpec.describe '商品詳細', type: :system do
  before do
    @item1 = FactoryBot.create(:item, :image)
    @item2 = FactoryBot.create(:item, :image)
    @item3 = FactoryBot.create(:item, :image, :sold_out)
  end
  context 'ログインしているとき' do 
    context '自分が出品した商品ページのとき' do 
      it 'ログインした上で自分が出品した商品詳細ページへアクセスした場合は、「商品の編集」「削除」のリンクが存在すること' do
        # ログインする
        visit new_user_session_path
        fill_in 'user[email]', with: @item1.user.email
        fill_in 'user[password]', with: @item1.user.password
        find('input[name="commit"]').click
        expect(current_path).to eq root_path
        # 自分の出品した商品ページへアクセスする
        find(:xpath, "//a[@href='/items/#{@item1.id}']").click
        # 商品詳細ページに「商品の編集」と「削除」のボタンがある
        expect(page).to have_link '商品の編集', href: edit_item_path(@item1)
        expect(page).to have_link '削除', href: item_path(@item1)
      end
      it 'ログインした上で自分が出品した商品詳細ページへアクセスした場合は、「購入画面に進む」のリンクが存在しないこと'do
        # ログインする
        visit new_user_session_path
        fill_in 'user[email]', with: @item1.user.email
        fill_in 'user[password]', with: @item1.user.password
        find('input[name="commit"]').click
        expect(current_path).to eq root_path
        # 自分の出品した商品のページへアクセスする
        find(:xpath, "//a[@href='/items/#{@item1.id}']").click
        # 商品詳細ページに「購入画面に進む」のボタンは無い
        expect(page).to have_no_link '購入画面に進む', href: item_transactions_path(@item1)
      end
    end
    context '自分が出品した商品ページではないとき' do
      it 'ログインした上で自分が出品していない商品詳細ページへアクセスした場合は、「購入画面に進む」のリンクが存在すること' do
        visit new_user_session_path
        fill_in 'user[email]', with: @item1.user.email
        fill_in 'user[password]', with: @item1.user.password
        find('input[name="commit"]').click
        expect(current_path).to eq root_path
        # 自分の出品した商品のページへアクセスする
        find(:xpath, "//a[@href='/items/#{@item2.id}']").click
        # 商品詳細ページに「購入画面に進む」のボタンがある
        expect(page).to have_link '購入画面に進む', href: item_transactions_path(@item2)
      end
      it 'ログインした上で自分が出品していない、売却済みの商品詳細ページへアクセスした場合は、「SoldOut」が表示されること' do
        # ログインする
        visit new_user_session_path
        fill_in 'user[email]', with: @item1.user.email
        fill_in 'user[password]', with: @item1.user.password
        find('input[name="commit"]').click
        expect(current_path).to eq root_path
        # 自分の出品した商品以外のページへアクセスする
        find(:xpath, "//a[@href='/items/#{@item3.id}']").click
        # SoldOutの文字が表示されている
        expect(page).to have_content 'Sold Out!!' # 正規表現を使いたい
      end
      it 'ログインした上で自分が出品していない商品詳細ページへアクセスした場合は、「商品の編集」「削除」のリンクが存在しないこと' do
        # ログインする
        visit new_user_session_path
        fill_in 'user[email]', with: @item1.user.email
        fill_in 'user[password]', with: @item1.user.password
        find('input[name="commit"]').click
        expect(current_path).to eq root_path
        # 自分の出品した商品以外のページへアクセスする
        find(:xpath, "//a[@href='/items/#{@item3.id}']").click
        # 「商品の編集」「削除」のリンクは存在しない
        expect(page).to have_no_link '商品の編集', href: edit_item_path(@item3)
        expect(page).to have_no_link '削除', href: item_path(@item3)
      end
    end
  end
  context 'ログインしてないとき' do
    it 'ログインせずに商品詳細ページへアクセスした場合は、「購入」のリンクが存在すること' do
      # トップページへ行く
      visit root_path
      # 商品のページへアクセスする
      find(:xpath, "//a[@href='/items/#{@item2.id}']").click
      # 商品詳細ページに「購入画面に進む」のボタンがある
      expect(page).to have_link '購入画面に進む', href: item_transactions_path(@item2)
    end
    it 'ログインせずに商品詳細ページへアクセスした場合は、「編集」「削除」のリンクは存在しないこと' do
      # トップページへ行く
      visit root_path
      # 商品のページへアクセスする
      find(:xpath, "//a[@href='/items/#{@item2.id}']").click
      # 「商品の編集」「削除」のリンクは存在しない
      expect(page).to have_no_link '商品の編集', href: edit_item_path(@item2)
      expect(page).to have_no_link '削除', href: item_path(@item2)
    end
  end
end

RSpec.describe '商品削除', type: :system do
  before do
    @item1 = FactoryBot.create(:item, :image)
    @item2 = FactoryBot.create(:item, :image)
  end
  context '商品削除ができるとき' do 
    it 'ログインした上で自分が出品した商品を削除をすると、商品のレコードが1つ減り、トップページへ遷移すること' do
      # ログインする
      visit new_user_session_path
      fill_in 'user[email]', with: @item1.user.email
      fill_in 'user[password]', with: @item1.user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 自分の出品した商品のページへアクセスする
      find(:xpath, "//a[@href='/items/#{@item1.id}']").click
      # 「削除」のリンクが存在する
      expect(page).to have_link '削除', href: item_path(@item1)
      # 「削除」のリンクをクリック
      expect{
        find(:xpath, "//a[@href='/items/#{@item1.id}']").click}.to change { Item.count }.by(-1)
      # トップページへ遷移する
      expect(page).to have_current_path(root_path)
    end
  end
end

RSpec.describe '商品購入', type: :system do
  before do
    @item1 = FactoryBot.create(:item, :image)
    @item2 = FactoryBot.create(:item, :image)
    @item3 = FactoryBot.create(:item, :image, :sold_out)
  end
  context '商品購入ができるとき' do 
    it 'ログインした上で自分が出品していない商品を購入すると、取引テーブルのレコードが1つ増え、トップページへ遷移し、一覧ページと詳細ページにて、「sold out」の文字が表示されていること' do
      # ログインする
      visit new_user_session_path
      fill_in 'user[email]', with: @item1.user.email
      fill_in 'user[password]', with: @item1.user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 自分の出品した以外の商品ページへアクセスする
      find(:xpath, "//a[@href='/items/#{@item2.id}']").click
      # 「購入画面に進む」のリンクが存在する
      expect(page).to have_link '購入画面に進む', href: item_transactions_path(@item2)
      # 「購入画面に進む」のリンクをクリック
      find(:xpath, "//a[@href='/items/#{@item2.id}/transactions']").click
      # 購入ページへ遷移
      expect(page).to have_content '購入内容の確認'
      # 項目を入力
      fill_in 'number', with: "4242424242424242"
      fill_in 'exp_month', with: "3"
      fill_in 'exp_year', with: "30"
      fill_in 'cvc', with: "123"
      fill_in 'postal_code', with: "123-4567"
      select "東京都", from: "prefecture"
      fill_in 'city', with: "渋谷区"
      fill_in 'addresses', with: "神南"
      fill_in 'building', with: "hogeビル"
      fill_in 'phone_number', with: "01234567890"
      # 購入ボタンを押す
      find('input[name="commit"]').click
      # アイテムトランザクションモデルのカウントが1上がる
      expect change{ ItemTransaction.count }.by(1)
      # トップページへ遷移する
      expect(page).to have_current_path(root_path)
      # 購入したアイテム２の要素を変数に入れる
      bought_item2 = find(:xpath, "//a[@href='/items/#{@item2.id}']")
      # 変数の中にSold Out!!の文字が存在する
      expect(bought_item2).to have_content 'Sold Out!!'
      # アイテム2の商品をクリックする
      bought_item2.click
      # アイテム2の商品詳細ページでも、Sold Out!! の文字が出ている
      expect(page).to have_content 'Sold Out!!'
    end
  end
  context '商品購入ができないとき' do 
    it 'ログインした上で自分が出品していない商品を購入しようとした場合でも、無効な値が入力された場合は、商品購入ページにてエラーメッセージ が表示されること' do
      # ログインする
      visit new_user_session_path
      fill_in 'user[email]', with: @item1.user.email
      fill_in 'user[password]', with: @item1.user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 自分の出品した以外の商品ページへアクセスする
      find(:xpath, "//a[@href='/items/#{@item2.id}']").click
      # 「購入画面に進む」のリンクが存在する
      expect(page).to have_link '購入画面に進む', href: item_transactions_path(@item2)
      # 「購入画面に進む」のリンクをクリック
      find(:xpath, "//a[@href='/items/#{@item2.id}/transactions']").click
      # 購入ページへ遷移
      expect(page).to have_content '購入内容の確認'
      # 項目を入力
      fill_in 'number', with: ""
      fill_in 'exp_month', with: ""
      fill_in 'exp_year', with: ""
      fill_in 'cvc', with: ""
      fill_in 'postal_code', with: ""
      fill_in 'city', with: ""
      fill_in 'addresses', with: ""
      fill_in 'building', with: ""
      fill_in 'phone_number', with: ""
      # 購入ボタンを押す
      find('input[name="commit"]').click
      expect(page).to have_content("購入内容の確認")
      # エラーメッセージのクラスが出現する
      expect(page).to have_css "div.error-alert" 
    end
    it 'ログインした上でも、自分が出品した商品へは商品の購入ボタンが表示されないこと' do
      # ログインする
      visit new_user_session_path
      fill_in 'user[email]', with: @item1.user.email
      fill_in 'user[password]', with: @item1.user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 自分の出品した以外の商品ページへアクセスする
      find(:xpath, "//a[@href='/items/#{@item1.id}']").click
      # 「購入画面に進む」のリンクは存在しない
      expect(page).to have_no_link '購入画面に進む', href: item_transactions_path(@item1)
    end
    it 'ログインした上で、自分が出品した商品の購入ページへ遷移しようとするとトップページにリダイレクトされること' do
      # ログインする
      visit new_user_session_path
      fill_in 'user[email]', with: @item1.user.email
      fill_in 'user[password]', with: @item1.user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 自分が出品した商品の購入ページへダイレクトに遷移
      visit item_transactions_path(@item1)
      # トップページへ戻される
      expect(current_path).to eq root_path
    end
    it 'ログインした上で、売却済みの商品の購入ページへ遷移しようとするとトップページにリダイレクトされること' do
      # ログインする
      visit new_user_session_path
      fill_in 'user[email]', with: @item1.user.email
      fill_in 'user[password]', with: @item1.user.password
      find('input[name="commit"]').click
      expect(current_path).to eq root_path
      # 購入済み商品の購入ページへダイレクトに遷移
      visit item_transactions_path(@item3)
      # トップページへ戻される
      expect(current_path).to eq root_path
    end
    it 'ログインしていないユーザーは、商品の購入ボタンを押すと、ログインページへ遷移すること' do
      # トップページへ遷移
      visit root_path
      # 商品ページへアクセスする
      find(:xpath, "//a[@href='/items/#{@item1.id}']").click
      # 「購入画面に進む」のリンクが存在する
      expect(page).to have_link '購入画面に進む', href: item_transactions_path(@item1)
      # 「購入画面に進む」のリンクをクリック
      find(:xpath, "//a[@href='/items/#{@item1.id}/transactions']").click
      # ログインページへ遷移させられる
      expect(current_path).to eq new_user_session_path
      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end
end

RSpec.describe '商品一覧', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @item1 = FactoryBot.create(:item, :image)
    @item2 = FactoryBot.create(:item, :image, :sold_out)
  end
  it 'ログインしているユーザーは、商品の一覧表示を確認でき、適切な内容が表示されていること' do
    # ログインする
    visit new_user_session_path
    fill_in 'user[email]', with: @user.email
    fill_in 'user[password]', with: @user.password
    find('input[name="commit"]').click
    expect(current_path).to eq root_path
    # ヘッダー画像がある
    expect(page).to have_content "人生を変えるフリマアプリ"
    # 出品ページへのリンクがある
    expect(page).to have_content('出品する')
    # 出品中の商品が存在している
    find(:xpath, "//a[@href='/items/#{@item1.id}']")    
    # 売却済みの商品も存在している
    find(:xpath, "//a[@href='/items/#{@item2.id}']")
  end
  it 'ログインしていないユーザーでも、商品の一覧表示を確認でき、適切な内容が表示されていること' do
    # ログインする
    visit root_path
    expect(current_path).to eq root_path
    # ヘッダー画像がある
    expect(page).to have_content "人生を変えるフリマアプリ"
    # 出品ページへのリンクがある
    expect(page).to have_content('出品する')
    # 出品中の商品が存在している
    find(:xpath, "//a[@href='/items/#{@item1.id}']")
    # 売却済みの商品も存在している
    find(:xpath, "//a[@href='/items/#{@item2.id}']")
  end
end
