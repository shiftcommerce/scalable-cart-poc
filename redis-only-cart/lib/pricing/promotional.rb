module Pricing
  module Promotional
    def self.[](sku)
      value = BigDecimal.new(sku[0].to_i(36))

      if value < 11
        value = value / 2
      end

      value
    end
  end
end
