module SDES
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
      Utility::rotate_left(bits.dec,1,5).bin(5)
    end

    def self._ls3(bits)
      Utility::rotate_left(bits.dec,3,5).bin(5)
    end

  end
end