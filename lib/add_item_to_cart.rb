require_relative 'cart'
require_relative 'stock_check'

module AddItemToCart
  def self.call(session, sku:, quantity:)
    cart = Cart.new(session)
    required_quantity = cart.quantity_for(sku) + quantity

    if StockCheck.call(sku) < required_quantity
      false
    else
      cart.add_item(sku: sku, quantity: quantity)
      cart.persist!
    end
  end
end
