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
    
    # Review this, ensure that it "rotates" the output
    # No tests written for this yet.
    def self.fk(bits,sk)
      left, right = bits[0..3], bits[4..7]
      mangled = (left.dec ^ f(right,sk).dec).bin(4)
      mangled + right
    end
    
    # [48, 48, 49, 48, 49] => ['0', '0', '1', '0', '1'] => '00101'
    def self.f(bits, subkey)
      e = expand(SDES::EP, bits).as_str.dec
      r = (e ^ subkey.dec).bin
      r1 = r[0..3]
      r2 = r[4..7]
      
      s0 = select_from(SDES::S0, r1).to_i.bin(2)
      s1 = select_from(SDES::S1, r2).to_i.bin(2)
      pr = (s0+s1).dec.bin(4)
      
      permute(P4,pr).as_str
    end
    
    # input: a string of ascii characters
    # output: a binary number as a string
    def self.encrypt(input, key)
      k1, k2 = SDES::Key.subkey(key)
      a = input.each_char.map do |c|
        bits = c[0].bin # convert to integer to bits
        ip = permute(Initial, bits).as_str
        m1 = fk(ip, k1)
        m2 = fk(flip(m1).as_str, k2) # m1 must be flipped???
        fp = permute(Final, m2).as_str
        fp
      end
      
      a.join
    end
    
    # input: a string of ascii characters
    # output: a binary number as a string
    def self.decrypt(input, key)
      k1, k2 = SDES::Key.subkey(key)
      a = input.scan(/[01]{8}/).map do |byte|
        fp = permute(Initial, byte).as_str
        m2 = fk(fp, k2) # m1 must be flipped???
        m1 = fk(flip(m2).as_str, k1)
        ip = permute(Final, m1).as_str
        ip.dec.chr
      end
      
      a.join
    end
    
    def self.select_from(map, bits)
      row = (bits[0].chr + bits[3].chr).dec
      col = (bits[1].chr + bits[2].chr).dec
      map[row*4+col]
    end
      
    def self.flip(a)
      permute(SDES::Flip, a)
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
  
  class Input < Struct.new(:file_name, :student_name, :key, :content, :mode)
    include SDES::Utility
    include SDES::Key
    
    def initialize(path)
      # we skip lines 4 and 5 on purpose
      f = open(path)
      line = f.readlines
      f.close
      
      self.file_name = line[0].chomp
      self.student_name = line[1].chomp
      self.mode = line[2].chomp
      self.key = line[3].chomp
      self.content = line[6]
      
    end
    
    def encrypt?
      self.mode && self.mode.downcase == "e"
    end
    
    def encrypt
      SDES::Utility.encrypt(self.content, self.key)
    end
    
    def to_s
      self.content
    end
    
  end
  
end

class Fixnum
  def bin(padding=8)
    SDES::Utility.dec_to_bin(self, padding)
  end
end

class Array
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
  
  def dec
    SDES::Utility.bin_to_dec(self)
  end

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
