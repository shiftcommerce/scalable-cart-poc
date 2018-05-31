require_relative 'cart'

module RemoveItemFromCart
  def self.call(session, sku:)
    cart = Cart.new(session)
    cart.remove_item(sku: sku)
    cart.persist!
  end
end
