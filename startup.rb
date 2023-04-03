require './lib/vending_machine'
require './lib/product'
require './lib/coin'

vending_machine = VendingMachine.new
products_to_load = [
  { name: 'Cola', price: 1.25, code: 100 },
  { name: 'Water', price: 2.75, code: 101 },
  { name: 'Chocolate', price: 4.5, code: 102 },
  { name: 'Cigarettes', price: 5.75, code: 103 }
]
coins_to_load = [0.25, 0.5, 1, 2, 3, 5]

products_to_load.each { |type| 5.times { vending_machine.product_storage.put(Product.new(type)) } }
coins_to_load.each { |type| 5.times { vending_machine.coin_changer.deposit(Coin.new(type)) } }

vending_machine.start!
