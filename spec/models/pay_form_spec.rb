require 'rails_helper'

RSpec.describe PayForm, type: :model do
  before do
    buyer = FactoryBot.create(:user)
    seller = FactoryBot.create(:user)
    item = FactoryBot.build(:item, user_id: seller.id)
    # createでもOK
    item.save
    @pay_form = FactoryBot.build(:pay_form, user_id: buyer.id, item_id: item.id)
    sleep(1)
  end
  describe '商品購入' do
    context '内容に問題ない場合' do
      it '全て正常' do
        expect(@pay_form.valid?).to eq true

      end
    end
    context '内容に問題がある場合' do
      it 'token:必須' do
        @pay_form.token = ''
        @pay_form.valid?
        expect(@pay_form.errors.full_messages).to include("Token can't be blank")
      end
      it 'postal_code:必須' do
        @pay_form.postal_code = ''
        @pay_form.valid?
        expect(@pay_form.errors.full_messages).to include("Postal code can't be blank")
      end
      it 'postal_code:フォーマット' do
        @pay_form.postal_code = '1234567'
        @pay_form.valid?
        expect(@pay_form.errors.full_messages).to include("Postal code Input correctly")
      end
      it 'prefecture:必須' do
        @pay_form.prefecture = nil
        @pay_form.valid?
        expect(@pay_form.errors.full_messages).to include("Prefecture can't be blank")
      end
      it 'prefecture:0以外' do
        @pay_form.prefecture = 0
        @pay_form.valid?
        expect(@pay_form.errors.full_messages).to include("Prefecture Select")
      end
      it 'city:必須' do
        @pay_form.city = ''
        @pay_form.valid?
        expect(@pay_form.errors.full_messages).to include("City can't be blank")
      end
      it 'addresses:必須' do
        @pay_form.addresses = ''
        @pay_form.valid?
        expect(@pay_form.errors.full_messages).to include("Addresses can't be blank")
      end
      it 'phone_number:必須' do
        @pay_form.phone_number = ''
        @pay_form.valid?
        expect(@pay_form.errors.full_messages).to include("Phone number can't be blank")
      end
      it 'phone_number:11桁以内' do
        @pay_form.phone_number = '1234567891011'
        @pay_form.valid?
        expect(@pay_form.errors.full_messages).to include("Phone number Too long")
      end
    end
  end
end