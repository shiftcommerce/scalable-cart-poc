require 'oj'
require 'securerandom'
require_relative 'pricing/default'

class Cart
  def initialize(session, prices: Pricing::Default, redis:)
    @redis = redis
    @session = session
    @cart_id = @session && @session[:cart_id]
    @items = Hash.new(0)
    @items.merge!(load_items) if @cart_id
    @cart_id ||= SecureRandom.uuid
    @prices = prices
  end

  attr_reader :items

  def quantity_for(sku)
    @items.fetch(sku, 0)
  end

  def add_item(sku:, quantity:)
    @items[sku] += quantity
  end

  def set_item_quantity(sku:, quantity:)
    if quantity == 0
      remove_item(sku: sku)
    else
      @items[sku] = quantity
    end
  end

  def remove_item(sku:)
    @items.delete(sku)
  end

  def persist!
    @redis.set(key, Oj.dump({ items: @items }, mode: :compat))
    @cart_id
  end

  def to_json
    Oj.dump({
      items: @items.map { |sku, quantity|
        price = @prices[sku]
        {
          sku: sku,
          quantity: quantity,
          each_price: price,
          line_price: quantity * price
        }
      }
    }, mode: :compat)
  end

  private
  def load_items
    Oj.load(@redis.get(key), symbol_keys: true).fetch(:items)
  end

  def key
    "carts/#{@cart_id}"
  end
end
