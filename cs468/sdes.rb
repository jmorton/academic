module SDES
  
  Initial = %w(2 6 3 1 4 8 5 7)
  
  Final = %w(4 1 3 5 7 2 8 6)
  
  EP = %w(4 1 2 3 2 3 4 1)
  
  P4 = %w(2 4 3 1)
  
  Flip = %w(5 6 7 8 1 2 3 4)
  
  S1 = %w(1 0 3 2
          3 2 1 0
          0 2 1 3
          3 1 3 2)
          
  S2 = %w(0 1 2 3
          2 0 1 3
          3 0 1 0
          2 1 0 3)
          
  P10 = %w(3 5 2 7 4 10 1 9 8 6)
  
  P8 = %w(6 3 7 4 8 5 10 9)
  
  module Key
    
    # input: a binary number as a string: "0000011111"
    # output: a pair of subkeys
    def self.subkey(key)

      if key.length != 10
        raise "Key must be of length 10 but was #{key.length}"
      end
      
      permuted_key = _p10(key)
      
      k1 = _p8( _ls1(_hi(permuted_key)) + _ls1(_lo(permuted_key)))
      k2 = _p8( _ls3(_hi(permuted_key)) + _ls3(_lo(permuted_key)))
      
      [k1, k2]
    end
    
    def self._p8(k)
      a = k.each_char.map { |c| c }
      Utility::permute(SDES::P8, a).to_s
    end
    
    def self._p10(k)
      a = k.each_char.map { |c| c }
      Utility::permute(SDES::P10, a).to_s
    end
    
    def self._hi(k)
      k[0..4].to_s
    end
    
    def self._lo(k)
      k[5..9].to_s
    end
    
    def self._ls1(a)
      v = Utility::bin_to_dec(a)
      Utility::rotate_left(v,1,5).bin(5)
    end
    
    def self._ls3(a)
      v = Utility::bin_to_dec(a)
      Utility::rotate_left(v,3,5).bin(5)
    end
    
  end
  
  module Utility
    
    def self.dec_to_bin(x, padding = 0)
      binary = x.to_i.to_s(2)
      (padding > 0) ? (binary.rjust(padding, "0")) : binary
    end
    
    def self.bin_to_dec(x)
      x.to_i(2)
    end
    
    def self.rotate_left(x, shift, max_size = 8)
      max_value = 2**max_size -1
      ((x<<shift) | (x >> (max_size -shift))) & max_value
    end
    
    def self.rotate_right(x, shift, max_size = 7)
      shift &= max_size
      max_value = (2 ** (max_size +1)) -1
      ((x << (max_size +1 -shift)) | (x>>shift)) & max_value
    end
    
    def self.mangle(input, key)
      left = input[0..3]
      right = input[4..7]
      subkey = SDES::Key.subkey(key)
      
      left ^ (expand(SDES::EP, right) ^ subkey.first)

    end
  
    def self.flip(a)
      self.permute(SDES::Flip, a)
    end
     
    def self.permute(mapping, values)
      # raise "Sizes of mapping (#{mapping.length}) and values (#{values.length}) differ when they shouldn't." if mapping.length != values.length
      mapping.collect { |index| values[index.to_i - 1] }
    end
    
    def self.expand(mapping, values)
      mapping.collect { |index| values[index.to_i - 1] }
    end
    
    def self.substitute(input, mapping, size=4, &block)
      row = SDES::Utility.bin_to_dec(input[0].chr + input[3].chr).to_i
      col = SDES::Utility.bin_to_dec(input[1].chr + input[2].chr).to_i
      if block_given?
        yield(row,col)
      else
        mapping[(row*size + col).to_i].to_i
      end
    end
    
  end
  
end

class Fixnum
  def bin(padding=0)
    SDES::Utility.dec_to_bin(self, padding)
  end
end
