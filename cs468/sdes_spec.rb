require 'sdes'

describe 'Input' do
  
  before(:each) do
    @input = SDES::Input.new('plain-test.txt')
  end
  
  it 'should parse an encrypted file' do
    @input.should_not be_blank
  end
  
  it 'should have the file name' do
    @input.file_name.should eql("plain-test.txt")
  end
  
  it 'should have the student name' do
    @input.student_name.should eql("Name of Student")
  end
  
  it 'should want to be encrypted' do
    @input.encrypt?.should be_true
  end
  
  it 'should have a key' do
    @input.key.should eql("")
  end
  
  it 'should have an initialization vector' do
    @input.initialization_vector.should eql("")
  end
  
  it 'should have plain text' do
    @input.plain_text.should eql("Technology is a way of organizing the universe so that man doesn't have to experience it.")
  end
  
end

describe 'Binary/Decimal conversion' do
  
  it 'should convert decimal to binary' do
    SDES::Utility.bin_to_dec("0").should eql(0)
    SDES::Utility.bin_to_dec("1").should eql(1)
    SDES::Utility.bin_to_dec("10").should eql(2)
  end
  
  it 'should convert binary to decimal' do
    0.bin(4).should eql("0000")
    1.bin(4).should eql("0001")
    2.bin(4).should eql("0010")
    4.bin(4).should eql("0100")
    8.bin(4).should eql("1000")
  end
end

describe 'Flip' do
  
  it 'Basic flipping works' do
    SDES::Utility.flip([1,2,3,4,5,6,7,8]).should eql([5,6,7,8,1,2,3,4])
  end
  
end

describe 'Permutation' do
  
  it 'should support permutation' do
    SDES::Utility.should respond_to(:permute)
  end
  
  it 'should perform basic permutation' do
    map = %w(3 2 1)
    values = %w(a b c)
    
    SDES::Utility.permute(map, values).should eql(values.reverse)
  end
  
  it 'should work when applying S-SDES initial and final permutation' do
    before_p =%w(a b c d e f g h)
    after_p  =%w(b f c a d h e g)
    SDES::Utility.permute(SDES::Initial, before_p).should eql(after_p)
    SDES::Utility.permute(SDES::Final, after_p).should eql(before_p)
  end
  
end

describe 'Expansion' do
  it 'should support expansion' do
    SDES::Utility.should respond_to(:expand)
  end
  
  it 'should perform basic expansion' do
    table  = %w(4 1 2 3 4 1)
    result = %w(d a b c d a)
    values = %w(a b c d)
    
    SDES::Utility.expand(table, values).should eql(result)
  end
end

describe 'Substitution' do
  it 'should support substitution' do
    SDES::Utility.should respond_to(:substitute)
  end
  
  it 'should perform basic substitution' do
    s1 = SDES::S1
    s2 = SDES::S2
    
    SDES::Utility.substitute("0000",s1).should eql(1)
    SDES::Utility.substitute("0001",s1).should eql(3)
    SDES::Utility.substitute("1111",s1).should eql(2)
    
    SDES::Utility.substitute("0000",s2).should eql(0)
    SDES::Utility.substitute("0001",s2).should eql(2)
    SDES::Utility.substitute("1111",s2).should eql(3)
  end
  
  it 'should calculate the row using the first and last char' do
    # Testing the row/col values that should be generated and
    # not the values that are in individual mappings.
    s1 = SDES::S1
    m1 = Proc.new { |row, column| [row, column] }
    
    SDES::Utility.substitute("0000",s1,&m1).should eql([0,0])
    SDES::Utility.substitute("0001",s1,&m1).should eql([1,0])
    SDES::Utility.substitute("0010",s1,&m1).should eql([0,1])
    SDES::Utility.substitute("0011",s1,&m1).should eql([1,1])
    SDES::Utility.substitute("0100",s1,&m1).should eql([0,2])
    SDES::Utility.substitute("0101",s1,&m1).should eql([1,2])
    SDES::Utility.substitute("0110",s1,&m1).should eql([0,3])
    SDES::Utility.substitute("1000",s1,&m1).should eql([2,0])
    SDES::Utility.substitute("1001",s1,&m1).should eql([3,0])
    SDES::Utility.substitute("1010",s1,&m1).should eql([2,1])
    SDES::Utility.substitute("1011",s1,&m1).should eql([3,1])
    SDES::Utility.substitute("1100",s1,&m1).should eql([2,2])
    SDES::Utility.substitute("1101",s1,&m1).should eql([3,2])
    SDES::Utility.substitute("1110",s1,&m1).should eql([2,3])
    SDES::Utility.substitute("1111",s1,&m1).should eql([3,3])
  end
 
end

describe 'Circular shifting' do
  
  it 'should rotate left correctly (with value of 1)' do
    SDES::Utility.rotate_left(1,1).should eql(2)
    SDES::Utility.rotate_left(1,2).should eql(4)
    SDES::Utility.rotate_left(1,3).should eql(8)
    SDES::Utility.rotate_left(1,4).should eql(16)
    SDES::Utility.rotate_left(1,5).should eql(32)
    SDES::Utility.rotate_left(1,6).should eql(64)
    SDES::Utility.rotate_left(1,7).should eql(128)
    SDES::Utility.rotate_left(1,8).should eql(1)
  end
  
  it 'should rotate left correctly' do
    SDES::Utility.rotate_left(255, 1).should eql(255)
    SDES::Utility.rotate_left(127, 1).should eql(255-1)
    SDES::Utility.rotate_left(63,  2).should eql(255-3)
  end
  
  it 'should rotate right correctly' do
    SDES::Utility.rotate_right(2,1).should eql(1)
    SDES::Utility.rotate_right(255,1).should eql(255)
  end
  
  it 'should rotate a five bit number correctly' do
    x = SDES::Utility.bin_to_dec("1100")
    y = SDES::Utility.rotate_left(x,2,4)
    z = SDES::Utility.dec_to_bin(y)
    z.should eql("11")
  end
  
end

describe 'Generating one key from another' do
  it 'should generate a pair' do
    keys = SDES::Key.subkey("1010000010")
    keys[0].should eql("10100100")
    keys[1].should eql("01000011")
  end
  
  it 'should permute using P10 correctly' do
    SDES::Key._p10("1010000010").should eql("1000001100")
  end
  
  it 'should split correctly' do
    SDES::Key._hi("1000001100").should eql("10000")
    SDES::Key._lo("1000001100").should eql("01100")
  end
  
  it 'should left shift by 1 correctly' do
    SDES::Key._ls1("10000").should eql("00001")
    SDES::Key._ls1("01100").should eql("11000")
  end
  
  it 'should left shift by 3 correctly' do
    SDES::Key._ls3("10000").should eql("00100")
    SDES::Key._ls3("01100").should eql("00011")
  end
  
  it 'should permute using P8 correctly' do
    SDES::Key._p8("0000111000").should eql("10100100")
    SDES::Key._p8("0010000011").should eql("01000011")
  end
  
end