require './lib/coin_values'

class CoinChanger
  attr_reader :storage

  include CoinValues

  def initialize
    @storage = {}
  end

  def deposit(coin)
    check_coin(coin.value)
    storage[coin.value] ||= []
    storage[coin.value].push(coin)
  end

  def withdraw(amount)
    return [] if (amount <= 0) || (amount > amount_in_storage)

    change = generate_change_list(amount)
    extract_coins_from_storage(change)
  end

  def withdraw_available?(amount)
    generate_change_list(amount).sum { |k, v| k * v } == amount
  end

  private

  def amount_in_storage
    storage.sum { |k, v| k * v.size }
  end

  def coins_in_changer
    storage.select { |_, v| v.size.positive? }
  end

  def generate_change_list(amount)
    coins_to_withdraw = {}
    remaining_amount = amount
    coins_in_changer.to_a.sort.reverse.each do |coin_value, coins|
      break if remaining_amount.zero?
      next if remaining_amount < coin_value

      required_coins_count, = remaining_amount.divmod(coin_value)
      coins_to_withdraw[coin_value] = [required_coins_count, coins.size].min
      remaining_amount -= coin_value * coins_to_withdraw[coin_value]
    end
    remaining_amount.zero? ? coins_to_withdraw : {}
  end

  def check_coin(value)
    return if VALID_COIN_VALUES.include?(value)

    raise ArgumentError, "Expected coins are  #{VALID_COIN_VALUES}, got #{value}"
  end

  def extract_coins_from_storage(change)
    coins = []
    change.each do |coin_value, coins_to_withdraw|
      coins_to_withdraw.times { coins << storage[coin_value].pop }
    end
    coins
  end
end
