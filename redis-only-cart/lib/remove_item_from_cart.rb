require_relative 'cart'

module RemoveItemFromCart
  def self.call(session, sku:, redis:)
    cart = Cart.new(session, redis: redis)
    cart.remove_item(sku: sku)
    cart.persist!
  end
end
