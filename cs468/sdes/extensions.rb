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
