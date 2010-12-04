#!/usr/bin/ruby

# output = %x(dineroIV -informat d -l1-dsize 16K -l1-dbsize 16 -l1-dassoc 2 -l1-drepl l < spice.din)
# puts output

cache_sizes = %w(2 4 8 16 32)
block_sizes = %w(16 32 64 128)

def simulate(cache_size, block_size)
  return %x(dineroIV -informat d -l1-usize #{cache_size}K -l1-ubsize #{block_size} < spice.din)
end

# Matches a string like this:
#   Demand miss rate	      0.1279	      0.0968	      0.2398	      0.2471	      0.2233	      0.0000
# And returns an array of the column values
#
def average_miss_rate(string)
  matches = string.scan(/Demand miss rate\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
  return matches[0]
end

# Reads a string like this:
#
# Total Bytes r/w Mem	     2418336
# ( / Demand Fetches)	      2.4183
#
# And returns a pair of values 2418336, 2.4183
#
def average_memory_traffic(string)
  matches = string.scan(/Total Bytes r\/w Mem\s+(\S+).+Demand Fetches[^0-9]+(\S+)/m)
  return matches[0]
end

puts "cache, block, miss rate, traffic"
rs = cache_sizes.map do |cache_size|
  block_sizes.map do |block_size|
    output = simulate(cache_size, block_size)
    result = [ cache_size, block_size, [ average_miss_rate(output)[0], average_memory_traffic(output)[1] ].flatten ]
    puts result.flatten.join(',')
    result
  end
end
