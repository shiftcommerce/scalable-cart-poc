module Pricing
  module Default
    def self.[](sku)
      BigDecimal.new(sku[0].to_i(36))
    end
  end
end
