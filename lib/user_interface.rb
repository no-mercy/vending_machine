require './lib/coin_values'

class UserInterface
  attr_reader :vending_machine

  include ActionStatuses
  include CoinValues

  def initialize(vending_machine)
    @vending_machine = vending_machine
  end

  def work_loop
    show_available_products
    loop { user_action }
  end

  private

  def user_action
    puts 'Please use one of commands: (p)rint products, (i)nsert coin, (s)elect product, (h)elp, (q)uit'
    print '>>'
    input = gets.chomp.downcase.split
    case input.first
    when 'p'
      show_available_products
    when 'i'
      insert_coin(input[1])
    when 's'
      select_product(input[1])
    when 'q'
      exit(0)
    else
      show_help
    end
  end

  def insert_coin(amount)
    if amount.to_f.positive? && VALID_COIN_VALUES.include?(amount.to_f)
      coin = Coin.new(amount)
      vending_machine.put_coin(coin)
      puts "You have inserted coin with amount of #{amount}, your current balance is #{vending_machine.current_balance}"
    else
      puts 'Wrong coin amount, command example: >>c 0.25'
    end
  end

  def select_product(product_code)
    return show_help unless product_code

    code = vending_machine.select_product(product_code.to_i)
    case code
    when PRODUCT_IS_OUT_OF_STOCK
      puts 'This product is currently not available'
    when NOT_ENOUGH_CASH
      puts 'Not enough cash, please insert few more coins to get desired product'
    when NOT_ENOUGH_CHANGE
      puts 'We are unable to give you a change, please select another product or insert a coin'
    when TRANSACTION_OK
      puts "Machine buzzing, now it's time to check trays"
      check_trays
    end
  end

  def show_help
    puts %(Just few examples how to use this:
      >>i 0.25
      >>i 5
      >>s 100
      >>p
      >>q)
  end

  def check_trays
    puts "You've got #{vending_machine.product_tray.pop.name} from product tray"
    vending_machine.change_tray.slice!(0, vending_machine.change_tray.size).each do |coin|
      puts "You have found coin of #{coin.value} in change tray"
    end
  end

  def show_available_products
    puts('Products available:')
    vending_machine.products_available.each do |product|
      puts "Name: #{product.name}, Price: #{product.price}, use code #{product.code} to buy it!"
    end
    puts "\nYour current balance is: #{vending_machine.current_balance}"
  end
end
