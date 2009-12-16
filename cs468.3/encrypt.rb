class Fixnum
  def bits(padding = 8)
    SDES::Utility.decimal_to_binary(self, padding)
  end
end
class Array
  def as_str
    self.map { |item| item.is_a?(Fixnum) ? (item.chr) : (item) }.to_s
  end
end
class String
  def base10
    SDES::Utility.binary_to_decimal(self)
  end
  def bits
    self.each_char.map { |c| c[0].bits }.to_s
  end
  def each_char
    block_given? ? (scan(/./m) { |x| yield(x) }) : (scan(/./m))
  end
end
module SDES
  class IO < Struct.new(:file_name, :student_name, :mode, :key, :cipher, :iv, :content)
    def process!
      result = (encrypt or decrypt)
      save!(result)
    end
    def initialize(path)
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
    def encrypt?
      (self.mode and (self.mode.downcase == "e"))
    end
    def decrypt?
      (self.mode and (self.mode.downcase == "d"))
    end
    def encrypt
      (encrypt? and SDES::Utility.encrypt(self.content, self.key))
    end
    def decrypt
      (decrypt? and SDES::Utility.decrypt(self.content, self.key))
    end
    def opposite_mode
      return "D" if self.encrypt?
      return "E" if self.decrypt?
      return "?"
    end
    def self.process(filelist)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      paths = open(filelist).readlines
      saved = paths.map do |path|
        SDES::IO.new(path.chomp).process! rescue "Could not process '#{path}'"
      end
      saved
    end
    def output_path
      other_prefix = "crypt-" if encrypt?
      other_prefix = "plain-" if decrypt?
      self.file_name.gsub(/\w+\-/, other_prefix)
    end
    protected
    def save!(result)
      open(output_path, "w").puts(output_path, student_name, opposite_mode, key, cipher, iv, result)
      output_path
    end
  end
  Initial = ["2", "6", "3", "1", "4", "8", "5", "7"]
  Final = ["4", "1", "3", "5", "7", "2", "8", "6"]
  EP = ["4", "1", "2", "3", "2", "3", "4", "1"]
  P4 = ["2", "4", "3", "1"]
  Flip = ["5", "6", "7", "8", "1", "2", "3", "4"]
  S0 = ["1", "0", "3", "2", "3", "2", "1", "0", "0", "2", "1", "3", "3", "1", "3", "2"]
  S1 = ["0", "1", "2", "3", "2", "0", "1", "3", "3", "0", "1", "0", "2", "1", "0", "3"]
  P10 = ["3", "5", "2", "7", "4", "10", "1", "9", "8", "6"]
  P8 = ["6", "3", "7", "4", "8", "5", "10", "9"]
  module Utility
    def self.j1(*args)
      @v2 ||= 7
      @v1 ||= 5
      (@v1 + @v2)
    end
    def self.j2(*args)
      @v4 ||= 10
      @v3 ||= 8
      (@v3 + @v4)
    end
    def self.j3(*args)
      @v2 ||= 4
      @v1 ||= 2
      (@v1 + @v2)
    end
    def self.j4(*args)
      @v4 ||= 7
      @v3 ||= 5
      (@v3 + @v4)
    end
    # do nothing
    # do nothing
    # do nothing
    # do nothing
    def self.f(bits, subkey)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      mix = subkey.base10.^(permute(SDES::EP, bits).base10).bits
      sub_1 = select_two_bits_from(SDES::S1, mix[(4..7)])
      sub_0 = select_two_bits_from(SDES::S0, mix[(0..3)])
      four_bits = (sub_1 + sub_0).base10.bits(4)
      permute(P4, four_bits)
    end
    def self.encrypt(input, key)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      key_1, key_2 = SDES::Key.subkey(key)
      bytes = input.each_char.map do |char|
        perm = permute(Initial, char.bits)
        round_1 = fk(perm, key_1)
        flipped = flip(round_1)
        round_2 = fk(flipped, key_2)
        permute(Final, round_2)
      end
      bytes.join
    end
    def self.decrypt(input, key)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      key_1, key_2 = SDES::Key.subkey(key)
      chars = input.scan(/[01]{8}/).map do |byte|
        perm = permute(Initial, byte)
        round_2 = fk(perm, key_2)
        flipped = flip(round_2)
        round_1 = fk(flipped, key_1)
        permute(Final, round_1).base10.chr
      end
      chars.join
    end
    def self.fk(bits, key)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      left, right = bits[(0..3)], bits[(4..7)]
      mangled = left.base10.^(f(right, key).base10).bits(4)
      (right + mangled)
    end
    def self.flip(a)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      permute(SDES::Flip, a)
    end
    def self.permute(mapping, values)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      mapping.collect { |index| values[(index.to_i - 1)] }.as_str
    end
    def self.decimal_to_binary(x, padding = 0)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      binary = x.to_i.to_s(2)
      (padding > 0) ? (binary.rjust(padding, "0")) : (binary)
    end
    def self.select_two_bits_from(mapping, bits)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      col = (bits[2].chr + bits[1].chr).base10
      row = (bits[3].chr + bits[0].chr).base10
      z = ((col + 4) * row)
      mapping[z].to_i.bits(2)
    end
    def self.binary_to_decimal(x)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      x.to_i(2)
    end
    def self.rotate_left(x, shift, max_size = 8)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      max_value = ((2 ** max_size) - 1)
      (x << shift).|((x >> (max_size - shift))).&(max_value)
    end
  end
  module Key
    def self.j1(*args)
      @v2 ||= 5
      @v1 ||= 3
      (@v1 + @v2)
    end
    def self.j2(*args)
      @v4 ||= 8
      @v3 ||= 6
      (@v3 + @v4)
    end
    def self.j3(*args)
      @v2 ||= 2
      @v1 ||= 0
      (@v1 + @v2)
    end
    def self.j4(*args)
      @v4 ||= 5
      @v3 ||= 3
      (@v3 + @v4)
    end
    # do nothing
    # do nothing
    # do nothing
    # do nothing
    def self._p8(str)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      a = str.each_char.map { |c| c }
      Utility.permute(SDES::P8, a).to_s
    end
    def self._p10(str)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      a = str.each_char.map { |c| c }
      Utility.permute(SDES::P10, a).to_s
    end
    def self.subkey(key)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      permuted_key = _p10(key)
      k2 = _p8((_ls3(_lo(permuted_key)) + _ls3(_hi(permuted_key))))
      k1 = _p8((_ls1(_lo(permuted_key)) + _ls1(_hi(permuted_key))))
      [k1, k2]
    end
    def self._hi(k)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      k[(0..4)].to_s
    end
    def self._lo(k)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      k[(5..9)].to_s
    end
    def self._ls1(bits)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      Utility.rotate_left(bits.base10, 1, 5).bits(5)
    end
    def self._ls3(bits)
      v2 = j3
      v4 = j1
      # do nothing
      # do nothing
      Utility.rotate_left(bits.base10, 3, 5).bits(5)
    end
  end
end
