require 'coin_changer'
require 'coin'

describe CoinChanger do
  let(:acceptable_coin_values) { described_class::VALID_COIN_VALUES }

  describe 'Constants' do
    it { expect(acceptable_coin_values).to eq([0.25, 0.5, 1, 2, 3, 5]) }
  end

  describe '#deposit' do
    subject { described_class.new }

    context 'when coins are correct ones' do
      it 'should correctly deposit coins into empty storage' do
        expect(subject.storage.size).to be_zero
        acceptable_coin_values.each do |coin_value|
          coin = Coin.new(coin_value)
          subject.deposit(coin)
        end
        expect(subject.storage.size).to eq(6)
      end

      it 'should correctly deposit given amount of coins into storage' do
        coin = Coin.new(acceptable_coin_values.take(1).last)
        10.times { subject.deposit(coin) }
        expect(subject.storage[coin.value].size).to eq(10)
      end
    end

    context 'when coins are incorrect ones' do
      let(:incorrect_coin) { Coin.new(acceptable_coin_values.max + 1) }

      it 'should fire ArgumentError exception' do
        expect { subject.deposit(incorrect_coin) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#withdraw' do
    subject { described_class.new }

    context 'when enough coins are present in storage' do
      before do
        acceptable_coin_values.each do |coin_value|
          coin = Coin.new(coin_value)
          5.times { subject.deposit(coin) }
        end
      end

      let(:expected_before_withdraw) { { 0.25 => 5, 0.5 => 5, 1.0 => 5, 2.0 => 5, 3.0 => 5, 5.0 => 5 } }
      let(:expected_after_first_withdraw) { { 0.25 => 4, 0.5 => 4, 1.0 => 4, 2.0 => 5, 3.0 => 4, 5.0 => 2 } }
      let(:expected_after_second_withdraw) { { 0.25 => 3, 0.5 => 3, 1.0 => 4, 2.0 => 5, 3.0 => 1, 5.0 => 0 } }
      let(:expected_after_third_withdraw) { { 0.25 => 2, 0.5 => 2, 1.0 => 0, 2.0 => 0, 3.0 => 0, 5.0 => 0 } }

      it 'should return correct list of coins, and storage should be changed' do
        expect(parse_storage_state(subject.storage)).to eq(expected_before_withdraw)
        expect(subject.withdraw(19.75).map(&:value)).to eq([5.0, 5.0, 5.0, 3.0, 1.0, 0.5, 0.25])
        expect(parse_storage_state(subject.storage)).to eq(expected_after_first_withdraw)
        expect(subject.withdraw(19.75).map(&:value)).to eq([5.0, 5.0, 3.0, 3.0, 3.0, 0.5, 0.25])
        expect(parse_storage_state(subject.storage)).to eq(expected_after_second_withdraw)
        expect(subject.withdraw(17.75).map(&:value)).to eq([3.0, 2.0, 2.0, 2.0, 2.0, 2.0, 1.0, 1.0, 1.0, 1.0, 0.5, 0.25])
        expect(parse_storage_state(subject.storage)).to eq(expected_after_third_withdraw)
      end
    end

    context 'when there are not enough coins present in storage' do
      let(:expected_before_withdraw) { { 0.25 => 1, 0.5 => 1, 1.0 => 1, 2.0 => 1, 3.0 => 1, 5.0 => 1 } }

      before do
        acceptable_coin_values.each do |coin_value|
          subject.deposit(Coin.new(coin_value))
        end
      end

      it 'should return empty list, and storage should not be changed' do
        expect(parse_storage_state(subject.storage)).to eq(expected_before_withdraw)
        expect(subject.withdraw(19.75)).to eq([])
        expect(parse_storage_state(subject.storage)).to eq(expected_before_withdraw)
      end
    end
  end

  describe '#withdraw_available?' do
    subject { described_class.new }

    context 'when enough coins are present' do
      before { 4.times { subject.deposit(Coin.new(0.25)) } }

      it { expect(subject.withdraw_available?(1)).to be_truthy }
    end

    context 'when enough cache is present, not enough coins for change' do
      before { 4.times { subject.deposit(Coin.new(0.50)) } }

      it { expect(subject.withdraw_available?(0.75)).to be_falsey }
    end

    context 'when not enough cache is present in storage' do
      before { 4.times { subject.deposit(Coin.new(0.50)) } }

      it { expect(subject.withdraw_available?(2.5)).to be_falsey }
    end

    context 'when no cache at all is present in storage' do
      it { expect(subject.withdraw_available?(0.25)).to be_falsey }
    end
  end

  private

  def parse_storage_state(storage)
    storage.inject({}) do |result, (k, v)|
      result[k] = v.size
      result
    end
  end
end
