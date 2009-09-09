module DES
  
  module Utility
  
    def self.permute(mapping, values)
      raise "Sizes of mapping and values differ when they shouldn't." if mapping.length != values.length
      mapping.collect { |index| values[index.to_i - 1] }
    end
    
  end
  
end