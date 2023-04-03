class ProductStorage
  attr_reader :storage

  def initialize
    @storage = {}
  end

  def put(product)
    storage[product.code] ||= []
    storage[product.code].push(product)
  end

  def get(product_code)
    storage[product_code].pop
  end

  def product_present?(product_code)
    storage[product_code]&.any? == true
  end

  def product_price(product_code)
    storage[product_code].first&.price
  end

  def products_list
    storage.inject([]) do |result, (_, v)|
      result.push(v.first) if v.size.positive?
      result
    end
  end
end
