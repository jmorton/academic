#!/usr/bin/ruby

# Example:
#
# Simulation do |with|
#   with.policies      LRU, Random
#   with.associativity 1, 2, 4, 8, 16
#   measure Miss
# end
#

class Simulator

  Options = {
    :cache_size  =>   '-l1-usize',
    :block_size  =>   '-l1-ubsize',
    :associative =>   '-l1-dassoc',
    :policy      =>   '-l1-drepl'
  }

  def initialize
    @default_cache_size = '16k'
    @command = 'dineroIV -informat d'
    @input = 'spice.din'
  end

  def cache_sizes(*args)
    @cache_sizes = *args
  end

  def block_sizes(*args)
    @block_sizes = *args
  end

  def policies(*args)
    @policies = *args
  end

  def associativity(*args)
    @associativities = *args
  end

  # Runs each permutation of the command based on the options.
  def run
    @results = Hash.new
    permutation.each do |options|
      simulation = Simulation.new(options).execute
      if block_given?
        @results[simulation.command] = yield(simulation)
      else
        @results[simulation.command] = simulation
      end
    end
  end

  def results
    @results
  end

  # Generate the next variation of choices
  def permutation
    @cache_sizes.map do |a|
      @block_sizes.map do |b|
        { :cache_size => a, :block_size => b }
      end
    end.flatten
  end

  # Create a simulator.
  def Simulator.setup(options = {}, &block)
    s = Simulator.new
    yield(s)
    s
  end

  # Encapsulates the idea of running a single simulation.  This makes it easier
  # to specify parameters and extract results.
  class Simulation
    attr_accessor :command, :result, :options

    Columns = %w(total instruction data read write misc).map { |c| c.intern }

    def initialize(options)
      arguments = options.map { |key, value| "#{Options[key]} #{value}" }.join(' ')
      self.command = "dineroIV -informat d #{arguments} < spice.din"
      self.options = options
    end

    def execute
      self.result = %x(#{self.command})
      self
    end

    def demand_miss_rate
      values = self.result.scan(/Demand miss rate\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
      Hash[Columns.zip(values[0])]
    end

    def demand_fetch_rate
      values = self.result.scan(/Fraction of total\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
      Hash[Columns.zip(values[0])]
    end

  end

end

s = Simulator.setup do |with|
  with.cache_sizes   %w(2K 4K 8K 16K)
  with.block_sizes   16, 32, 64, 128
end

s.run do |simulation|
  p simulation.demand_miss_rate
  p simulation.demand_fetch_rate
end


