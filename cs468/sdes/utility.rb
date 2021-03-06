module SDES
  module Utility
  
    # input: a string of ascii characters
    # output: a binary number as a string
    def self.encrypt(input, key)
      key_1, key_2 = SDES::Key.subkey(key)
      
      bytes = input.each_char.map do |char|
        round_1 = fk(permute(Initial, char.bits), key_1)
        round_2 = fk(flip(round_1), key_2)
        permute(Final, round_2)
      end
  
      bytes.join
    end

    # input: a binary number as a string
    # output: a string of ascii characters
    def self.decrypt(input, key)
      key_1, key_2 = SDES::Key.subkey(key)
      
      chars = input.scan(/[01]{8}/).map do |byte|
        round_2 = fk(permute(Initial, byte), key_2)
        round_1 = fk(flip(round_2), key_1)
        permute(Final, round_1).base10.chr
      end
  
      chars.join
    end

    # Review this, ensure that it "rotates" the output.
    # No tests written for this *yet* because it is used
    # by f(), encrypt(), and decrypt() all of which
    # have tests. Still, it deserves coverage.
    def self.fk(bits,key)
      left, right = bits[0..3], bits[4..7]
      mangled = (left.base10 ^ f(right,key).base10).bits(4)
      mangled + right
    end

    # The nitty gritty mangler used by fk().  Even though the
    # code can be inspected, what it does is not immediately
    # obvious.
    def self.f(bits, subkey)
      # Apply subkey to string of bits.  Since both are a string representing
      # the binary value, they must be converted so that XOR can be correctly
      # applied.
      mix = (subkey.base10 ^ permute(SDES::EP, bits).base10).bits
      
      # Use the left most bits and right most bits to obtain two bits each
      # from S0 and S1.
      sub_0 = select_two_bits_from(SDES::S0, mix[0..3])
      sub_1 = select_two_bits_from(SDES::S1, mix[4..7])
      
      # Combine the bit strings ("01" + "10" = "0110").
      # By calling .bits(4) the string is not padded with
      # extra zeros.
      four_bits = (sub_0 + sub_1).base10.bits(4)
      
      # The final operation permutes the four_bits
      permute(P4, four_bits)
    end

    # This will only work with an array of eight items since
    # this is accomplished using a table instead of a pure
    # function.
    def self.flip(a)
      permute(SDES::Flip, a)
    end
 
    def self.permute(mapping, values)
      mapping.collect { |index| values[index.to_i - 1] }.as_str
    end

    # Used by f() to grab values from S0 and S1 (mapping)
    # by using a string of 4 bits.  The row is selected
    # using the first and last bits and the column is selected
    # using the middle two bits.
    # examples:
    # - "1010" means row "10" (2) and col "01" (1)
    # - "0011" means row "00" (0) and col "11" (3)
    def self.select_two_bits_from(mapping, bits)
      row = (bits[0].chr + bits[3].chr).base10
      col = (bits[1].chr + bits[2].chr).base10
      mapping[row*4+col].to_i.bits(2)
    end
  
    def self.decimal_to_binary(x, padding = 0)
      binary = x.to_i.to_s(2)
      (padding > 0) ? (binary.rjust(padding, "0")) : binary
    end

    def self.binary_to_decimal(x)
      x.to_i(2)
    end

    def self.rotate_left(x, shift, max_size = 8)
      max_value = 2**max_size -1
      ((x<<shift) | (x >> (max_size -shift))) & max_value
    end

  end
end