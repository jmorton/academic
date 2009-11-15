# Pseudo code taken from http://en.wikipedia.org/wiki/SHA_hash_functions and adapted.
module SHA2
  # 
  # H0 = 0x6a09e667
  # H1 = 0xbb67ae85
  # H2 = 0x3c6ef372
  # H3 = 0xa54ff53a
  # H4 = 0x510e527f
  # H5 = 0x9b05688c
  # H6 = 0x1f83d9ab
  # H7 = 0x5be0cd19
  # 
  # # Initialize table of round constants
  # # (first 32 bits of the fractional parts of the cube roots of the first 64 primes 2..311):
  # K = [
  #    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  #    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  #    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  #    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  #    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  #    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  #    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  #    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  #  ]
  # 
  # # Note 2: All constants are big endian
  # def hexdigest(m)
  # 
  #   # Initialize variables
  #   # (first 32 bits of the fractional parts of the square roots of the first 8 primes 2..19):
  #   h0 = H0
  #   h1 = H1
  #   h2 = H2
  #   h3 = H3
  #   h4 = H4
  #   h5 = H5
  #   h6 = H6
  #   h7 = H7
  # 
  #   # Pre-processing:
  #   # append the bit '1' to the message
  #   # append k bits '0', where k is the minimum number >= 0 such that the resulting message
  #   #     length (in bits) is congruent to 448 (mod 512)
  #   # append length of message (before pre-processing), in bits, as 64-bit big-endian integer
  # 
  #   # Process the message in successive 512-bit (64 byte) chunks:
  #   m.in_groups_of(64) do |chunk|
  #     chunk.in_groups_of(4) do |word| 
  #       break chunk into sixteen 32-bit big-endian words w[0..15]
  # 
  #       # Extend the sixteen 32-bit words into sixty-four 32-bit words:
  #       for i from 16 to 63
  #           s0 := (w[i-15] rightrotate 7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift 3)
  #           s1 := (w[i-2] rightrotate 17) xor (w[i-2] rightrotate 19) xor (w[i-2] rightshift 10)
  #           w[i] := w[i-16] + s0 + w[i-7] + s1
  # 
  #       # Initialize hash value for this chunk:
  #       a = h0
  #       b = h1
  #       c = h2
  #       d = h3
  #       e = h4
  #       f = h5
  #       g = h6
  #       h = h7
  # 
  #       # Main loop:
  #       for i from 0 to 63
  #           s0 = (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
  #           maj = (a and b) xor (a and c) xor (b and c)
  #           t2 = s0 + maj
  #           s1 = (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
  #           ch = (e and f) xor ((not e) and g)
  #           t1 = h + s1 + ch + K[i] + w[i]
  # 
  #           h = g
  #           g = f
  #           f = e
  #           e = d + t1
  #           d = c
  #           c = b
  #           b = a
  #           a = t1 + t2
  # 
  #       # Add this chunk's hash to result so far:
  #       h0 = h0 + a
  #       h1 = h1 + b 
  #       h2 = h2 + c
  #       h3 = h3 + d
  #       h4 = h4 + e
  #       h5 = h5 + f
  #       h6 = h6 + g 
  #       h7 = h7 + h
  # 
  #   # Produce the final hash value (big-endian):
  #   # digest = hash = h0 + h1 + h2 + h3 + h4 + h5 + h6 + h7
  #   [h0,h1,h2,h3,h4,h5,h6,h7].join
  # end
  
end

class Object
  def returning(value)
    yield(value)
    value
  end
end

# Taken from the Rails framework (yes... it's open source)
class Array
  def in_groups_of(number, fill_with = nil)
    if fill_with == false
      collection = self
    else
      # size % number gives how many extra we have;
      # subtracting from number gives how many to add;
      # modulo number ensures we don't add group of just fill.
      padding = (number - size % number) % number
      collection = dup.concat([fill_with] * padding)
    end

    if block_given?
      collection.each_slice(number) { |slice| yield(slice) }
    else
      returning [] do |groups|
        collection.each_slice(number) { |group| groups << group }
      end
    end
  end
end

"0123456789ABCDEFGHIJKL".bytes.to_a.in_groups_of(8, 0) { |group| p group }