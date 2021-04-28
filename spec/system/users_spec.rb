require 'rails_helper'

RSpec.describe 'ユーザー新規登録', type: :system do
  before do
    @user = FactoryBot.build(:user)
  end
  context 'ユーザー新規登録ができるとき' do 
    it '有効な情報で新規登録を行うと、レコードが1つ増え、トップページへ遷移すること' do
      # トップページに移動する
      visit root_path
      # トップページにサインアップページへ遷移するボタンがある
      expect(page).to have_content('新規登録')
      # 新規登録ページへ移動する
      click_on '新規登録'
      # ユーザー情報を入力する
      fill_in 'user[nickname]', with: @user.nickname
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      fill_in 'user[password_confirmation]', with: @user.password
      fill_in 'user[first_name]', with: @user.first_name
      fill_in 'user[last_name]', with: @user.last_name
      fill_in 'user[first_name_kana]', with: @user.first_name_kana
      fill_in 'user[last_name_kana]', with: @user.last_name_kana
      select "1930", from: "user[birth_day(1i)]"
      select "1", from: "user[birth_day(2i)]"
      select "1", from: "user[birth_day(3i)]"
      # 会員登録ボタンを押すとユーザーモデルのカウントが1上がる
      expect{
        find('input[name="commit"]').click
      }.to change { User.count }.by(1)
      # トップページへ遷移する
      expect(page).to have_current_path(root_path)
      # 新規登録の文字が消えている 不要？
      expect(page).to have_no_content('新規登録')
      # 登録したニックネームが表示されている 不要？
      expect(page).to have_content(@user.nickname)
    end
  end

  context 'ユーザー新規登録ができないとき' do
    it '無効な情報で新規登録を行うと、新規登録画面にて、エラーが表示されること' do
      # トップページに移動する
      visit root_path
      # トップページにサインアップページへ遷移するボタンがある
      expect(page).to have_content('新規登録')
      # 新規登録ページへ移動する
      click_on '新規登録'
      # 間違ったユーザー情報を入力する
      fill_in 'user[nickname]', with: ""
      fill_in 'user[email]', with: ""
      fill_in 'user[password]', with: ""
      fill_in 'user[password_confirmation]', with: ""
      fill_in 'user[first_name]', with: ""
      fill_in 'user[last_name]', with: ""
      fill_in 'user[first_name_kana]', with: ""
      fill_in 'user[last_name_kana]', with: ""
      # 会員登録ボタンを押してもユーザーモデルのカウントは上がらない
      expect{
        find('input[name="commit"]').click
      }.to change { User.count }.by(0)
      # 新規登録ページへ戻される
      expect(page).to have_content("会員情報入力") #renderしているため、current_pathが使えない？パス情報が変わる
      expect(page).to have_css "div.error-alert" #_error_messages.html.erbは配布されているのか
      # expect(page).to have_content("Email can't be blank") #不要？受講生によって異なっていてもOKなのか
      # expect(page).to have_content("Password can't be blank")
      # expect(page).to have_content("Password Include both letters and numbers")
      # expect(page).to have_content("Nickname can't be blank")
    end
  end
end

RSpec.describe 'ログイン', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end
  context 'ログインができるとき' do 
    it '有効な情報でログインを行うと、トップページへ遷移すること' do
      # トップページに移動する
      visit root_path
      # トップページにサインアップページへ遷移するボタンがある
      expect(page).to have_content('ログイン')
      # 新規登録ページへ移動する
      click_on 'ログイン'
      # ユーザー情報を入力する
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      # ログインボタンを押す
      find('input[name="commit"]').click
      # トップページへ遷移する
      expect(page).to have_current_path(root_path)
      # ログアウトの文字が表示されている 不要？
      expect(page).to have_content('ログアウト')
      # 登録したニックネームが表示されている 不要？
      expect(page).to have_content(@user.nickname)
      # 新規登録の文字が消えている 不要？
      expect(page).to have_no_content('新規登録')
      # ログインの文字が消えている 不要？
      expect(page).to have_no_content('ログイン')
    end
  end

  context 'ログインができないとき' do 
    it '無効な情報でログインを行うと、ログインページにて、エラーメッセージ が表示されること' do
      # トップページに移動する
      visit root_path
      # トップページにサインアップページへ遷移するボタンがある
      expect(page).to have_content('ログイン')
      # 新規登録ページへ移動する
      click_on 'ログイン'
      # ユーザー情報を入力する
      fill_in 'user[email]', with: ""
      fill_in 'user[password]', with: ""
      # ログインボタンを押す
      find('input[name="commit"]').click
      # トップページへ遷移する
      expect(page).to have_content("会員情報入力")
      # エラーメッセージが出現している 受講生によるカスタマイズは発生するのか
      expect(page).to have_content("Invalid Email or password.")
    end
  end
end