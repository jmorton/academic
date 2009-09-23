#
# author: Jon Morton
#
# = About
# A simplified and less secure version of DES.  This was implemented
# as part of my coursework for CS 468 at George Mason University. If
# you use this code commercially, you're making a huge mistake.
#
# = Important Notes
# 1. I did not take an object oriented approach to implementing the majority
# of the cryptographic functions.
# 2. I've "monkey-patched" String, Fixnum, and Array.  Usually, this practice
# is discouraged unless you really know what you're doing (which I do) and
# this code should not be used in a large scale system.  Therefore, even though
# adding to the standard classes can make things complicated it makes the code
# far more expressive.
#


require 'sdes/tables'
require 'sdes/key'
require 'sdes/utility'
require 'sdes/input'

class Fixnum
  
  # Converts a number into a byte long binary number.
  #
  # Examples:
  # 15.bin # => 00001111
  # 6.bin(4) # => 0110
  def bin(padding=8)
    SDES::Utility.dec_to_bin(self, padding)
  end
end

class Array
  
  # Converts an array elements into a string.  If the element is a fixnum
  # it will convert it into a string first.  This makes changing a permuted
  # array back into an actual string.  Even though to_s will accomplish this
  # in some cases, this will not convert fixnums into chars.
  def as_str
    self.map do |i|
      if Fixnum === i
        i.chr
      else
        i
      end
    end.to_s
  end
end

class String
  
  # Convert a binary number represented as a string and converts it into
  # a fixnum in base ten.
  #
  # Examples:
  # "1001".dec #=> 9
  #
  def dec
    SDES::Utility.bin_to_dec(self)
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
