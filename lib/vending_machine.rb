require './lib/action_statuses'
require './lib/user_interface'
require './lib/product_storage'
require './lib/coin_changer'

class VendingMachine
  attr_reader :product_storage, :coin_changer, :coin_acceptor, :user_interface
  attr_accessor :product_tray, :change_tray

  include ActionStatuses

  def initialize
    @product_storage = ProductStorage.new
    @coin_changer = CoinChanger.new
    @coin_acceptor = []
    @product_tray = []
    @change_tray = []
    @user_interface = UserInterface.new(self)
  end

  def put_coin(coin)
    coin_acceptor << coin
  end

  def select_product(product_code)
    return PRODUCT_IS_OUT_OF_STOCK unless product_storage.product_present?(product_code)
    return NOT_ENOUGH_CASH unless purchase_balance_valid?(product_code)
    return NOT_ENOUGH_CHANGE unless change_is_available?(product_code)

    transaction!(product_code)
  end

  def current_balance
    coin_acceptor.sum(&:value)
  end

  def products_available
    product_storage.products_list
  end

  def start!
    user_interface.work_loop
  end

  private

  def purchase_balance_valid?(product_code)
    product_storage.product_price(product_code) <= coin_acceptor.sum(&:value)
  end

  def change_is_available?(product_code)
    coin_changer.withdraw_available?(change_amount(product_code))
  end

  def transaction!(product_code)
    change_tray.concat(coin_changer.withdraw(change_amount(product_code)))
    coin_acceptor.reject! { |coin| coin_changer.deposit(coin) }
    product_tray << product_storage.get(product_code)
    TRANSACTION_OK
  end

  def change_amount(product_code)
    coin_acceptor.sum(&:value) - product_storage.product_price(product_code)
  end
end
