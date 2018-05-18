require 'oj'

class Cart
  def initialize(session)
    @session = session
    @items = Hash.new(0)
    @items.merge!(parsed_session.fetch(:items, {}))
  end

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
      items: @items
    })
  end

  private
  def parsed_session
    @parsed_session ||= Oj.load(@session[:cart])
  end
end
