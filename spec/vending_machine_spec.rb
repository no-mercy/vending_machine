require 'vending_machine'

describe VendingMachine do
  describe '#put_coin' do
    subject { described_class.new }

    it 'should receive coins into coin acceptor' do
      expect(subject.coin_acceptor.sum).to eq(0)
      subject.put_coin(5)
      expect(subject.coin_acceptor.sum).to eq(5)
      subject.put_coin(0.25)
      expect(subject.coin_acceptor.sum).to eq(5.25)
    end
  end

  describe '#select_product' do
    subject { described_class.new }

    context 'when selected product is absent' do
      it 'should return appropriate error' do
        expect(subject.select_product(100)).to eq(ActionStatuses::PRODUCT_IS_OUT_OF_STOCK)
      end
    end

    context 'when selected product is present' do
      let(:product) { Product.new(name: 'Cola', price: 1.25, code: 100) }

      before { subject.product_storage.put(product) }

      context 'when no enough cash is present in coin acceptor' do
        it 'should return appropriate error' do
          expect(subject.select_product(product.code)).to eq(ActionStatuses::NOT_ENOUGH_CASH)
        end
      end

      context 'when enough cash is present but CoinChanger is unable to give change' do
        before { subject.coin_changer.deposit(Coin.new(0.5)) }

        it 'should return appropriate error' do
          subject.put_coin(Coin.new(2))
          expect(subject.select_product(product.code)).to eq(ActionStatuses::NOT_ENOUGH_CHANGE)
        end
      end

      context 'when enough cash is present' do
        before { subject.coin_changer.deposit(Coin.new(0.25)) }

        it 'should return appropriate status, and put product and change in related trays, coin acceptor should be empty' do
          subject.put_coin(Coin.new(1))
          subject.put_coin(Coin.new(0.5))
          expect(subject.select_product(product.code)).to eq(ActionStatuses::TRANSACTION_OK)
          expect(subject.product_tray.first).to eq(product)
          expect(subject.change_tray.flatten.first.value).to eq(0.25)
          expect(subject.coin_acceptor).to be_empty
        end
      end
    end
  end
end
