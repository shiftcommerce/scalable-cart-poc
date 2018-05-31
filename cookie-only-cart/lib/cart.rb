require 'oj'
require_relative 'pricing/default'

class Cart
  def initialize(session, prices: Pricing::Default)
    @session = session
    @items = Hash.new(0)
    @items.merge!(parsed_session.fetch(:items, {}))
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
    @session[:cart] = Oj.dump({
      items: @items
    })
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
  def parsed_session
    @parsed_session ||= begin
      if @session[:cart]
        Oj.load(@session[:cart], symbol_keys: true)
      else
        {}
      end
    end
  end
end
