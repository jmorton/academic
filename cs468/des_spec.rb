require 'des'

describe 'Binary/Decimal conversion' do
  
  it 'should convert decimal to binary' do
    DES::Utility.bin_to_dec("0").should eql(0)
    DES::Utility.bin_to_dec("1").should eql(1)
    DES::Utility.bin_to_dec("10").should eql(2)
  end
  
  it 'should convert binary to decimal' do
    DES::Utility.dec_to_bin(0).should eql("0")
  end
end

describe 'Permutation' do
  
  it 'should support permutation' do
    DES::Utility.should respond_to(:permute)
  end
  
  it 'should perform basic permutation' do
    map = %w(3 2 1)
    values = %w(a b c)
    
    DES::Utility.permute(map, values).should eql(values.reverse)
  end
  
  it 'should work when applying S-DES initial and final permutation' do
    before_p =%w(a b c d e f g h)
    after_p  =%w(b f c a d h e g)
    DES::Utility.permute(DES::Initial, before_p).should eql(after_p)
    DES::Utility.permute(DES::Final, after_p).should eql(before_p)
  end
  
  it 'should complain about differently sized maps and values' do
    map = %w(3, 2, 1)
    values = %w(a b c d)
    
    lambda {
      DES::Utility.permute(map, values)
    }.should raise_error
  end
  
end

describe 'Expansion' do
  it 'should support expansion' do
    DES::Utility.should respond_to(:expand)
  end
  
  it 'should perform basic expansion' do
    table  = %w(4 1 2 3 4 1)
    result = %w(d a b c d a)
    values = %w(a b c d)
    
    DES::Utility.expand(table, values).should eql(result)
  end
end

describe 'Substitution' do
  it 'should support substitution' do
    DES::Utility.should respond_to(:substitute)
  end
  
  it 'should perform basic substitution' do
    s1 = DES::S1
    s2 = DES::S2
    
    DES::Utility.substitute("0000",s1).should eql(1)
    DES::Utility.substitute("0001",s1).should eql(3)
    DES::Utility.substitute("1111",s1).should eql(2)
    
    DES::Utility.substitute("0000",s2).should eql(0)
    DES::Utility.substitute("0001",s2).should eql(2)
    DES::Utility.substitute("1111",s2).should eql(3)
  end
  
  it 'should calculate the row using the first and last char' do
    # Testing the row/col values that should be generated and
    # not the values that are in individual mappings.
    s1 = DES::S1
    m1 = Proc.new { |row, column| [row, column] }
    
    DES::Utility.substitute("0000",s1,&m1).should eql([0,0])
    DES::Utility.substitute("0001",s1,&m1).should eql([1,0])
    DES::Utility.substitute("0010",s1,&m1).should eql([0,1])
    DES::Utility.substitute("0011",s1,&m1).should eql([1,1])
    DES::Utility.substitute("0100",s1,&m1).should eql([0,2])
    DES::Utility.substitute("0101",s1,&m1).should eql([1,2])
    DES::Utility.substitute("0110",s1,&m1).should eql([0,3])
    DES::Utility.substitute("1000",s1,&m1).should eql([2,0])
    DES::Utility.substitute("1001",s1,&m1).should eql([3,0])
    DES::Utility.substitute("1010",s1,&m1).should eql([2,1])
    DES::Utility.substitute("1011",s1,&m1).should eql([3,1])
    DES::Utility.substitute("1100",s1,&m1).should eql([2,2])
    DES::Utility.substitute("1101",s1,&m1).should eql([3,2])
    DES::Utility.substitute("1110",s1,&m1).should eql([2,3])
    DES::Utility.substitute("1111",s1,&m1).should eql([3,3])
  end
 
end