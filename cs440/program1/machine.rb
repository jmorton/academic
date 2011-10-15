# Author: Jon Morton
#
# Release under The MIT License (MIT)
# Copyright (c) 2011, Jonathan Morton
#
# Emulator provides a simple machine for executing Instructions.
#
# It has separate memory stores for code, data, and registers. Emulator
# maintains a stack pointer in register zero.  It keeps an instruction
# pointer in it's own memory location.
#
# Emulator implements fetch, execute, run, and halt independently.
#
# Invalid instructions are displayed to STDOUT. 
# 
require './instructions'

class Emulator
  
  attr_accessor :code, :data, :register, :last_instruction,
  :instruction_pointer, :stack_pointer

  STACK_START = 500

  def initialize(instructions)
    @code = []
    @data = []
    @register = []
    @instruction_pointer, @stack_pointer = 0, STACK_START
    load!(instructions)
  end

  def stack_pointer
    @register[0]
  end

  def stack_pointer=(arg)
    @register[0] = arg
  end

  # Gets the next instruction as a list of opcode, arg1, arg2
  #
  # @return List<Fixnum, Fixnum, Fixnum>
  # 
  def fetch!
    @last_instruction = @code[@instruction_pointer,3]
    @instruction_pointer += 3
    @last_instruction
  end
  
  # Invokes the given instruction
  #
  # @param triple
  #   1st - instruction number
  #   2nd - arg1
  #   3rd - arg2
  # 
  # @return nil
  # 
  def execute!(triple)
    Instruction[ triple.first ].execute( self, triple[1], triple[2] ) rescue p triple
  end

  # Moves an instruction into the code section of the machine.  It does
  # not check for invalid insructions (non-numeric items).
  # 
  # @param [String] instruction
  # 
  # @return [Array<Fixnum, Fixnum, Fixnum>] instructions
  # 
  # Example:
  # 
  # 2  701  1    => [2,701,1]
  # 2  800  62   => [2,800,62]
  # 2  801  32   => [2,801,32]
  # 
  def load!(instruction)
    instruction.each_line do |line|
      @code.push(*line.scan(/\d+/).map { |string| string.to_i } )
    end

    return @code
  end

  # Run successive instructions until halted or instructions are exhausted.
  #
  # @return nil
  # 
  def run!
    @running = true
    
    while @running and (@instruction_pointer < @code.length)
      execute!(fetch!)
    end
    
    return nil
  end

  # Signal termination by moving the instruction
  # 
  # @return nil
  # 
  def halt!
    @running = false
    return nil
  end
  
end

# Get the machine code and run it
# 
if ARGV.length == 0
  puts "Specify the name of the file!  ruby machine.rb sample.txt"
else
  @program_text = open(ARGV.shift).read
  @emu = Emulator.new(@program_text)
  @emu.run!
end
