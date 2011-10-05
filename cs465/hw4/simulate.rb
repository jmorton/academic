#!/usr/bin/ruby

# Matches a string like this:
#   Demand miss rate        0.1279        0.0968        0.2398        0.2471        0.2233        0.0000
# And returns an array of the column values
#
def average_miss_rate(string)
  matches = string.scan(/Demand miss rate\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
  return matches[0]
end

# Reads a string like this:
#
# Total Bytes r/w Mem      2418336
# ( / Demand Fetches)       2.4183
#
# And returns a pair of values 2418336, 2.4183
#
def average_memory_traffic(string)
  matches = string.scan(/Total Bytes r\/w Mem\s+(\S+).+Demand Fetches[^0-9]+(\S+)/m)
  return matches[0]
end

# Wraps the command for simulating cache and block variations
def simulate_cache_block(cache_size, block_size)
  return %x(dineroIV -informat d -l1-usize #{cache_size}K -l1-ubsize #{block_size} < spice.din)
end

def measure_cache_block_size_effect
  cache_sizes = %w(2 4 8 16 32)
  block_sizes = %w(16 32 64 128)

  puts "+" + "\t" + block_sizes.join("\t")
  rs = cache_sizes.map do |cache_size|
    row = block_sizes.map do |block_size|
      output = simulate_cache_block(cache_size, block_size)
      yield(output)
    end
    puts cache_size + "\t" + row.join("\t")
    row
  end
  rs
end

def simulate_replacement_policy(associativity, policy)
  %x(dineroIV -informat d -l1-dsize 16K -l1-dbsize 16 -l1-dassoc #{associativity} -l1-drepl #{policy} < spice.din)
end

def measure_policy_associativity_effect
  policies = %w(r l)
  associativies = %w(1 2 4 8 16)

  puts "+" + "\t" + associativies.join("\t")
  rs = policies.map do |policy|
    cs = associativies.map do |associativity|
      output = simulate_replacement_policy(associativity, policy)
      yield(output)
    end
    puts policy + "\t" + cs.join("\t")
    cs
  end
  rs
end

# Example:
# Measure.policies.associativity # => { <policies> => <associativity> => [metrics] }
# Simulation do |with|
#   with.policies      LRU, Random
#   with.associativity 1, 2, 4, 8, 16
#   measure Miss
# end
def measure(a1, a2)
  rs = a1.value
end

puts "Analyzing miss rate"
measure_cache_block_size_effect do |output|
  average_miss_rate(output)[0]
end

puts "Analyzing memory traffic"
measure_cache_block_size_effect do |output|
  average_memory_traffic(output)[1]
end

puts "Analyzing miss rate for different LRU"
measure_policy_associativity_effect do |output|
  average_miss_rate(output)[0]
end

puts "Analyzing memory traffic for different LRU"
measure_policy_associativity_effect do |output|
  average_memory_traffic(output)[1]
end

