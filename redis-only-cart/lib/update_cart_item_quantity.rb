require_relative 'cart'
require_relative 'stock_check'

module UpdateCartItemQuantity
  def self.call(session, sku:, quantity:, redis:)
    cart = Cart.new(session, redis: redis)
    # only check the stock if quantity > 0 and we're increasing the quantity
    if quantity > 0 && quantity > cart.quantity_for(sku) && StockCheck.call(sku) < quantity
      false
    else
      cart.set_item_quantity(sku: sku, quantity: quantity)
      cart.persist!
    end
  end
end
