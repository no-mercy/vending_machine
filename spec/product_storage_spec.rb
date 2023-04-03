require 'product_storage'
require 'product'

describe ProductStorage do

  describe '#put' do
    subject { described_class.new }
    let(:product) { Product.new(name: 'Cola', price: 1.25, code: 100) }
    let(:product_2) { Product.new(name: 'Cola', price: 1.25, code: 100) }
    let(:product_3) { Product.new(name: 'Water', price: 2.75, code: 101) }

    it 'should correctly put product into storage' do
      expect(subject.storage[product.code]).to be_nil
      subject.put(product)
      expect(subject.storage[product.code].size).to eq(1)
      subject.put(product_2)
      expect(subject.storage[product_2.code].size).to eq(2)
      subject.put(product_3)
      expect(subject.storage[product_3.code].size).to eq(1)
    end
  end

  describe '#get' do
    subject { described_class.new }
    let(:cola_product_code) { 100 }
    let(:product) { Product.new(name: 'Cola', price: 1.25, code: cola_product_code) }
    let(:product_2) { Product.new(name: 'Cola', price: 1.25, code: cola_product_code) }
    let(:product_3) { Product.new(name: 'Water', price: 2.75, code: 101) }

    before do
      [product, product_2, product_3].each { |p| subject.put(p) }
    end

    it 'should correctly get product from storage by code if it is present, and return nil if not' do
      expect(subject.storage[cola_product_code].size).to eq(2)
      expect(subject.get(cola_product_code)).to eq(product_2)
      expect(subject.storage[cola_product_code].size).to eq(1)
      expect(subject.get(cola_product_code)).to eq(product)
      expect(subject.storage[cola_product_code].size).to eq(0)
      expect(subject.get(cola_product_code)).to be_nil
      expect(subject.get(product_3.code)).to eq(product_3)
      expect(subject.storage[product_3.code].size).to eq(0)
      expect(subject.get(product_3.code)).to be_nil
    end
  end

  describe '#product_present?' do
    subject { described_class.new }
    let(:cola_product_code) { 100 }
    let(:product) { Product.new(name: 'Cola', price: 1.25, code: cola_product_code) }

    before do
      subject.put(product)
    end

    it 'should correctly return availability of product by code' do
      expect(subject.product_present?(cola_product_code)).to be_truthy
      subject.get(cola_product_code)
      expect(subject.product_present?(cola_product_code)).to be_falsey
    end
  end

  describe '#product_price' do
    subject { described_class.new }
    let(:cola_product_code) { 100 }
    let(:product) { Product.new(name: 'Cola', price: 1.25, code: cola_product_code) }

    before do
      subject.put(product)
    end

    it 'should correctly return price of product by code or nil if product is absent' do
      expect(subject.product_price(cola_product_code)).to eq(1.25)
      subject.get(cola_product_code)
      expect(subject.product_price(cola_product_code)).to be_nil
    end
  end
end
