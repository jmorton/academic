class Fixnum
  
  # Converts a number into a byte long binary number.
  #
  # Examples:
  # 15.bits # => 00001111
  # 6.bits(4) # => 0110
  def bits(padding=8)
    SDES::Utility.decimal_to_binary(self, padding)
  end
end

class Array
  
  # Converts an array elements into a string.  If the element is a fixnum
  # it will convert it into a string first.  This makes changing a permuted
  # array back into an actual string.  Even though to_s will accomplish this
  # in some cases, this will not convert fixnums into chars.
  def as_str
    self.map { |item| item.is_a?(Fixnum) ? item.chr : item }.to_s
  end
end

class String
  
  # Convert a binary number represented as a string and converts it into
  # a fixnum in base ten.
  #
  # Examples:
  # "1001" #=> 9
  #
  def base10
    SDES::Utility.binary_to_decimal(self)
  end
  
  def bits
    self.each_char.map { |c| c[0].bits }.to_s
  end
  
  # This very useful method exists in ruby 1.8.7+ and but if we're running
  # on 1.8.6 the program won't run at all.
  def each_char
    if block_given?
      scan(/./m) do |x|
        yield x
      end
    else
      scan(/./m)
    end
  end

end

module SDES
  
  Initial = %w(2 6 3 1 4 8 5 7)

  Final = %w(4 1 3 5 7 2 8 6)

  EP = %w(4 1 2 3 2 3 4 1)

  P4 = %w(2 4 3 1)

  Flip = %w(5 6 7 8 1 2 3 4)

  S0 = %w(1 0 3 2
          3 2 1 0
          0 2 1 3
          3 1 3 2)
        
  S1 = %w(0 1 2 3
          2 0 1 3
          3 0 1 0
          2 1 0 3)
        
  P10 = %w(3 5 2 7 4 10 1 9 8 6)

  P8 = %w(6 3 7 4 8 5 10 9)
  
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
  
  class IO < Struct.new(:file_name, :student_name, :mode, :key, :cipher, :iv, :content)
  
    def initialize(path)
      # we skip lines 4 and 5 on purpose because this implementation
      # does not need to support any streaming ciphers
      f = open(path)
      line = f.readlines
      f.close
    
      self.file_name = line[0].chomp
      self.student_name = line[1].chomp
      self.mode = line[2].chomp
      self.key = line[3].chomp
      self.cipher = line[4].chomp
      self.iv = line[5].chomp
      self.content = line[6]
    end
  
    def process!
      result = encrypt || decrypt
      save!(result)
    end
    
    def encrypt?
      self.mode && self.mode.downcase == "e"
    end
  
    def decrypt?
      self.mode && self.mode.downcase == "d"
    end
  
    def encrypt
      encrypt? && SDES::Utility.encrypt(self.content, self.key)
    end
  
    def decrypt
      decrypt? && SDES::Utility.decrypt(self.content, self.key)
    end
    
    def opposite_mode
      return "D" if self.encrypt? 
      return "E" if self.decrypt?
      return "?"
    end
  
    def output_path
      other_prefix = 'crypt-' if encrypt?
      other_prefix = 'plain-' if decrypt?
      self.file_name.gsub(/\w+\-/, other_prefix)
    end
    
    def self.process(filelist)
      paths = open(filelist).readlines
      saved = paths.map do |path|
        begin
          SDES::IO.new(path.chomp).process!
        rescue
          "Could not process '#{path}'"
        end
      end
      
      saved
    end
    
    protected
    
    def save!(result)
      open(output_path, "w").puts(output_path, student_name, opposite_mode, key, cipher, iv, result)
      output_path
    end
  
  end

  module Key
  
    # input: a binary number as a string: "0000011111"
    # output: a pair of subkeys
    def self.subkey(key)
      permuted_key = _p10(key)
      k1 = _p8( _ls1(_hi(permuted_key)) + _ls1(_lo(permuted_key)))
      k2 = _p8( _ls3(_hi(permuted_key)) + _ls3(_lo(permuted_key)))
      [k1, k2]
    end

    def self._p8(str)
      a = str.each_char.map { |c| c }
      Utility::permute(SDES::P8, a).to_s
    end

    def self._p10(str)
      a = str.each_char.map { |c| c }
      Utility::permute(SDES::P10, a).to_s
    end

    def self._hi(k)
      k[0..4].to_s
    end

    def self._lo(k)
      k[5..9].to_s
    end

    def self._ls1(bits)
      Utility::rotate_left(bits.base10,1,5).bits(5)
    end

    def self._ls3(bits)
      Utility::rotate_left(bits.base10,3,5).bits(5)
    end

  end
end