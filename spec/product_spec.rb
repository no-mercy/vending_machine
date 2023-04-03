require 'product'

describe Product do
  describe '#initialize' do
    subject { described_class.new(name: 'Cola', price: 1.25, code: 100) }

    it { expect(subject.name).to eq('Cola') }
    it { expect(subject.price).to eq(1.25) }
    it { expect(subject.code).to eq(100) }
  end
end
