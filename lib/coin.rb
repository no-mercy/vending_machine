class Coin
  attr_reader :value

  def initialize(value)
    @value = value.to_f
  end
end
