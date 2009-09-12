module DES
  
  Initial = %w(2 6 3 1 4 8 5 7)
  
  Final = %w(4 1 3 5 7 2 8 6)
  
  S1 = %w(1 0 3 2
          3 2 1 0
          0 2 1 3
          3 1 3 2)
          
  S2 = %w(0 1 2 3
          2 0 1 3
          3 0 1 0
          2 1 0 3)
          
  module Utility
  
    def self.dec_to_bin(x)
      x.to_i.to_s(2)
    end
    
    def self.bin_to_dec(x)
      x.to_i(2)
    end
    
    def self.permute(mapping, values)
      raise "Sizes of mapping and values differ when they shouldn't." if mapping.length != values.length
      mapping.collect { |index| values[index.to_i - 1] }
    end
    
    def self.expand(mapping, values)
      mapping.collect { |index| values[index.to_i - 1] }
    end
    
    def self.substitute(input, mapping, size=4, &block)
      row = DES::Utility.bin_to_dec(input[0].chr + input[3].chr).to_i
      col = DES::Utility.bin_to_dec(input[1].chr + input[2].chr).to_i
      if block_given?
        yield(row,col)
      else
        mapping[(row*size + col).to_i].to_i
      end
    end
    
  end
  
end