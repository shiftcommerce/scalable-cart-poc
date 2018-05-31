# frozen_string_literal: true

require 'sinatra'
require 'oj'
require_relative 'lib/add_item_to_cart'
require_relative 'lib/remove_item_from_cart'
require_relative 'lib/update_cart_item_quantity'
require_relative 'lib/cart'
require_relative 'lib/pricing/promotional'

enable :sessions

SUCCESSFUL_ACTION_RESPONSE = [201, '{}'].freeze
EMPTY_CART_RESPONSE = [200, '{"items":[]}'].freeze

post '/add_item_to_cart' do
  params = Oj.load(request.body.read)
  sku = params.fetch('sku')
  quantity = params.fetch('quantity').to_i

  if session[:cart] = AddItemToCart.call(session, sku: sku, quantity: quantity)
    SUCCESSFUL_ACTION_RESPONSE
  else
    [422, '{ "error": "Unable to add item to cart" }']
  end
end

post '/remove_item_from_cart' do
  params = Oj.load(request.body.read)
  sku = params.fetch('sku')

  session[:cart] = RemoveItemFromCart.call(session, sku: sku)
  SUCCESSFUL_ACTION_RESPONSE
end

post '/update_cart_item_quantity' do
  params = Oj.load(request.body.read)
  sku = params.fetch('sku')
  quantity = params.fetch('quantity').to_i

  if session[:cart] = UpdateCartItemQuantity.call(session, sku: sku, quantity: quantity)
    SUCCESSFUL_ACTION_RESPONSE
  else
    [422, '{ "error": "Stock not available to service" }']
  end
end

get '/cart' do
  if session[:cart]
    [200, Cart.new(session, prices: Pricing::Promotional).to_json]
  else
    EMPTY_CART_RESPONSE
  end
end
