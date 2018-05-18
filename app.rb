# frozen_string_literal: true

require 'sinatra'
require 'oj'
require_relative 'lib/add_item_to_cart'
require_relative 'lib/remove_item_from_cart'
require_relative 'lib/update_cart_item_quantity'

enable :sessions

post '/add_item_to_cart' do
  params = Oj.load(request.body.read)
  sku = params.fetch('sku')
  quantity = params.fetch('quantity').to_i

  if AddItemToCart.call(session, sku: sku, quantity: quantity)
    [201, '{}']
  else
    [422, '{ "error": "Unable to add item to cart" }']
  end
end

post '/remove_item_from_cart' do
  params = Oj.load(request.body.read)
  sku = params.fetch('sku')

  RemoveItemFromCart.call(session, sku: sku)
  [201, '{}']
end

post '/update_cart_item_quantity' do
  params = Oj.load(request.body.read)
  sku = params.fetch('sku')
  quantity = params.fetch('quantity').to_i

  if UpdateCartItemQuantity.call(session, sku: sku, quantity: quantity)
    [201, '{}']
  else
    [422, '{ "error": "Stock not available to service" }']
  end
end

get '/cart' do
  [200, Cart.new(session).to_json]
end
