require 'coin'

describe Coin do
  describe '#initialize' do
    it { expect(described_class.new(0.25).value).to eq(0.25) }
    it { expect(described_class.new('0.25').value).to eq(0.25) }
  end
end
