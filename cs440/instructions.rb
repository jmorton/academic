I = Array.new
I[  1 ] = Proc.new { |m,d,e| m.data[d] = m.data[e]        }
I[  2 ] = Proc.new { |m,d,n| m.data[d] = n                }
I[ 11 ] = Proc.new { |m,d,e| m.data[d] = m.data[d] - m.data[e] }
I[ 29 ] = Proc.new { |m,d|   print m.data[d]              }
I[ 30 ] = Proc.new { |m,d|   print m.data[d].chr          }
I[ 31 ] = Proc.new {         print "\n"                   }
I[ 32 ] = Proc.new { |m,d|   m.data[d] = gets.to_i        }
I[ 36 ] = Proc.new { |m|     m.halt!                      }

I[ 21 ] = Proc.new do |m,a,d|
  if m.data[d] >= 0
    m.instruction_pointer = a - 1 # else the increment following screws this up
  end
end

