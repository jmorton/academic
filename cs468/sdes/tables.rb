# Tables used by permutation functions.  These are all predefined,
# but not by me.
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
end