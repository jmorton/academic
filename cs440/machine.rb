require './instructions'

class Emulator
  
  attr_accessor :code
  attr_accessor :data
  attr_accessor :register
  attr_accessor :instruction_pointer

  def initialize(instructions)
    @code = []
    @data = []
    @register = []
    @instruction_pointer = 0
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
  def fetch
    @code[@instruction_pointer]
  end
  
  # Invokes the given instruction
  #
  # @return nil
  # 
  def execute(i)
    I[i.first].call( self, i[1], i[2] )
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
      @code << line.scan(/\d+/).map { |string| string.to_i }
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
      execute(fetch)
      @instruction_pointer += 1
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
