class Product
  attr_reader :name, :price, :code

  def initialize(name:, price:, code:)
    @name = name
    @price = price
    @code = code
  end
end
