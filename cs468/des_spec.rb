require 'des'

describe 'Permutation' do
  
  it 'should support permutation' do
    DES::Utility.should respond_to(:permute)
  end
  
  it 'should perform basic permutation' do
    map = %w(3, 2, 1)
    values = %w(a b c)
    
    DES::Utility.permute(map, values).should eql(values.reverse)
  end
  
  it 'should complain about differently sized maps and values' do
    map = %w(3, 2, 1)
    values = %w(a b c d)
    
    lambda {
      DES::Utility.permute(map, values)
    }.should raise_error
  end
  
end

