Debug = false

# Author: Jonathan Morton
#
# Release under The MIT License (MIT)
# Copyright (c) 2011, Jonathan Morton
# 
# Instruction represents a PVM instruction.  A valid PVM instruction responds to
# (has a function named) 'execute' that takes three parameters.  The first
# parameter is a reference to a PVM machine.
#
# Upon creation, each instruction is registered with the Instruction class to make
# finding instances of Instruction using an opcode easier.  Each
#
# @todo:
# - Write some automated tests
# - Consider explicit conversion of types for boolean instructions
# - Add tracing function to Instruction base class
# 
class Instruction

  @set = Array.new
  
  attr_accessor :opcode, :mnemonic

  # Create a new Instruction
  # 
  def initialize(opcode, mnemonic, &block)
    self.opcode, self.mnemonic = opcode, mnemonic
    
    if block_given?
      metaclass = class << self; self; end
      metaclass.send :define_method, :execute, block
    end
    
    Instruction[opcode] = self
  end

  # Get an instruction
  # 
  # @param Fixnum ix - opcode of instruction
  # 
  # @return Instruction
  # 
  def self.[](ix)
    @set[ix]
  end

  # Set an instruction.
  #
  # @param Fixnum ix - opcode of instruction
  #
  # @todo - consider better expression, perhaps:
  # 
  #    Instruction << mvi
  # 
  def self.[]=(ix, value)
    @set[ix] = value
  end

  def display(m, a1 = nil, a2 = nil)
    printf("%2d:%5s\t%d\t%d\t%d\n", self.opcode, self.mnemonic, m.stack_pointer, a1, a2)
  end  
  
end

Instruction.new( 1, 'mov' ) do |m, d, e|
  printf("\n%2d:%5s\t(%03d)\t%4d\t=\t%4d\t(%03d)\t", self.opcode, self.mnemonic, d, m.data[d], m.data[e], e) if Debug
  m.data[d] = m.data[e]
end

Instruction.new( 2, 'mvi' ) do |m, d, n|
  printf("\n%2d:%5s\t(%03d)\t%4d\t=\t%4d\t\t", self.opcode, self.mnemonic, d, m.data[d], n) if Debug
  m.data[d] = n
end

Instruction.new( 3, 'mif' ) do |m, d, e|
  printf("\n%2d:%5s\t(%03d)\t%4d\t=\t%4d\t(%03d)\t", self.opcode, self.mnemonic, d, m.data[d], m.data[e], e) if Debug
  m.data[d] = m.data[m.data[e]]
end

Instruction.new( 4, 'mit' ) do |m, d, e|
  printf("\n%2d:%5s\t(%03d)\t%4d\t=\t%4d\t(%03d)\t", self.opcode, self.mnemonic, d, m.data[d], m.data[e], e) if Debug
  m.data[m.data[d]] = m.data[e]
end

Instruction.new( 5, 'lri' ) do |m, r, n|
  m.register[r] = n # test
end

Instruction.new( 6, 'ldr' ) do |m, r, d|
  m.register[r] = d # test
end

Instruction.new( 7, 'str' ) do |m, d, r|
  m.data[d] = m.register[r] # test
end

Instruction.new( 8, 'mvr' ) do |m, r, s|
  m.register[r] = m.register[s] # test
end

Instruction.new( 9, 'add' ) do |m, d, e|
  printf("\n%2d:%6s\t(%03d)\t%4d\t+\t%4d\t(%03d)\t", self.opcode, self.mnemonic, d, m.data[d], m.data[e], e)  if Debug
  m.data[d] = m.data[d].to_i + m.data[e].to_i
end

Instruction.new( 10, 'addri' ) do |m, r, n|
  m.register[r] += n # test
end

Instruction.new( 11, 'sub' ) do |m, d, e|
  m.data[d] = m.data[d].to_i - m.data[e].to_i
end

Instruction.new( 12, 'mul' ) do |m, d, e|
  printf("\n%2d:%6s\t(%03d)\t%4d\t*\t%4d\t(%03d)\t", self.opcode, self.mnemonic, d, m.data[d], m.data[e], e) if Debug
  m.data[d] *= m.data[e] # test
end

Instruction.new( 13, 'div' ) do |m, d, e|
  m.data[d] /= m.data[e] # test
end

Instruction.new( 14, 'or' ) do |m, d, e|
  m.data[d] = m.data[d] || m.data[e] # test
end

Instruction.new( 15, 'and' ) do |m, d, e|
  m.data[d] = m.data[d] && m.data[e] # test
end

Instruction.new( 16, 'not' ) do |m, d, _|
  m.data[d] = ! m.data[d]
end

Instruction.new( 17, 'b' ) do |m, a, _|
  m.instruction_pointer = a # test
end

Instruction.new( 18, 'beq' ) do |m, a, d|
  m.instruction_pointer = a if m.data[d] == 0 # test (to_i?)
end

Instruction.new( 19, 'bne' ) do |m, a, d|
  m.instruction_pointer = a if m.data[d] != 0 # test (to_i?)
end

Instruction.new( 20, 'bgt' ) do |m, a, d|
  m.instruction_pointer = a if m.data[d] > 0 # test (to_i?)
end

Instruction.new( 21, 'bge' ) do |m,a,d|
  if m.data[d] >= 0
    m.instruction_pointer = a
  end
end

Instruction.new( 22, 'blt' ) do |m, a, d|
  m.instruction_pointer = a if m.data[d] < 0 # test (to_i?)
end

Instruction.new( 23, 'ble' ) do |m, a, d|
  m.instruction_pointer = a if m.data[d] <= 0 # test (to_i?)
end

Instruction.new( 24, 'pushd' ) do |m, d, x|
  m.stack_pointer -= 1
  m.data[m.stack_pointer] = m.data[d] # test
  printf("\n%2d:%6s\t(%03d)\t%4d\t->\t\t(%03d)\t", self.opcode, self.mnemonic, d, m.data[d], m.stack_pointer) if Debug
end

Instruction.new( 25, 'pushr' ) do |m, r, x|
  m.stack_pointer -= 1
  m.data[m.stack_pointer] = m.register[r] # test
end

Instruction.new( 26, 'pushi' ) do |m, n, _|
  m.stack_pointer -= 1
  m.data[m.stack_pointer] = n # test
  printf("\n%2d:%6s\t\t%4d\t->\t\t(%03d)\t", self.opcode, self.mnemonic, n, m.stack_pointer) if Debug
end

Instruction.new( 27, 'popd' ) do |m, d, _|
  printf("\n%2d:%6s\t(%03d)\t\t<-\t%4d\t(%03d)\t", self.opcode, self.mnemonic, d, m.data[m.stack_pointer], m.stack_pointer) if Debug
  m.data[d] = m.data[m.stack_pointer]
  m.stack_pointer += 1
end

Instruction.new( 28, 'popr' ) do |m, r, _|
  m.register[r] = m.data[m.stack_pointer]
  m.stack_pointer += 1
end

Instruction.new 29, 'puti' do |m,d,x|
  printf("\n%2d:%6s\t(%03d)\t%4d\t\t\n", self.opcode, self.mnemonic, d, m.data[d]) if Debug
  print m.data[d]
end
  
Instruction.new 30, 'puts' do |m,d,x| # Up to a null character
  printf("\n%2d:%6s\t(%03d)\t%4d\t\t\n", self.opcode, self.mnemonic, d, m.data[d]) if Debug
  while m.data[d] != nil or m.data[d] == 0
    print m.data[d].chr
    d += 1
  end
end

Instruction.new 31, 'line' do |m,d,x|
  print "\n"
end

Instruction.new 32, 'geti' do |m,d,x|
  m.data[d] = gets.to_i
  printf("\n%2d:%6s\t(%03d)\t%4d\t\t", self.opcode, self.mnemonic, d, m.data[d])
end

Instruction.new 33, 'gets' do |m,d,x|
  array_of_chars = gets.chomp.chars.to_a
  m.data[d..(d+array_of_chars.length)] = array_of_chars
  printf("\n%2d:%6s\t(%03d)\t%4s\t\t", self.opcode, self.mnemonic, d, m.data[d..(d+array_of_chars.length)].inspect.to_s) if Debug
end

Instruction.new 34, 'call' do |m, a, _| # test
  m.data[m.stack_pointer] = m.instruction_pointer
  m.instruction_pointer = a
end

Instruction.new 35, 'ret' do |m, n, _| # test
  m.stack_pointer -= n
  m.instruction_pointer = m.data[m.stack_pointer]
end

Instruction.new 36, 'stop' do |m,d,x|
  m.halt!
end
