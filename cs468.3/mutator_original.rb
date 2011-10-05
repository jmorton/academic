require 'ruby2ruby-1.2.4/lib/ruby2ruby'
require 'ruby_parser-2.0.4/lib/ruby_parser'
require 'sexp_path/lib/sexp_path'
require 'pp'

# Adds junk functions and calls.
class Eve < SexpProcessor
  
  def initialize()
    super && self.strict = self.require_empty = ! self.auto_shift_type = true
    # Random values for functions, variables, operations, and s-expressions
    @fs = ['j1', 'j2', 'j3', 'j4']
    @vs = ['v1', 'v2', 'v3', 'v4']
    @os = [:+,  :-,  :*]
    @ns = (1..9).to_a
    @ss = [
      lambda { |f, x,y,z, n|
        s(:block,
          s(:op_asgn_or, s(:ivar, y), s(:iasgn, y, s(:lit, n+1))),
          s(:op_asgn_or, s(:ivar, x), s(:iasgn, x, s(:lit, n-1))),
          s(:call, s(:ivar, x), :+, s(:arglist, s(:ivar, y)))
        )
      }
    ]
  end

  # Births and invokes new functions
  def rewrite_block(exp)
    add_junk_methods(add_junk_calls(exp))
    exp
  end
  
  # Generate random junk functions
  def add_junk_methods(exp)
    # Functions should be added at the global scope.  If context is empty,
    # then we're at global scope.
    return exp unless valid_definition_context?
    
    h = exp.shift    
    [:j1, :j2, :j3, :j4].reverse.each do |f|
      exp.unshift( s(:defs, s(:self), f, s(:args, :"*args"), s(:scope, random_exp)))
    end
    
    exp.unshift(h)
  end
  
  # Put useless expressions into the code:
  # - plain statements
  # - identity for numbers
  # - double reverse strings
  # - set local variable
  def add_junk_calls(exp)
    # Don't add top level junk...
    return exp unless valid_call_context?
    
    exp.insert 1, s(:lasgn, random_variable, s(:call, nil, random_call, s(:arglist)))
    exp.insert 1, s(:lasgn, random_variable, s(:call, nil, random_call, s(:arglist)))
    exp
  end
  
  def nop_missing(exp)
    return (exp / Q?{ any( s(:defs,s(:self),:nop,_,_) ) }).empty?
  end
  
  def valid_definition_context?
    context == [:scope, :module, :block, :scope, :module, :block]    
  end

  def valid_call_context?
    Array === context and context[0..1] == [:scope, :defs]
  end
  
  # Gets a random index number
  def ix(n = 4)
    @ix ||= Time.now.to_i
    @ix += 1
    @ix % n
  end
  
  # Obtains a random function name
  def random_call()
    @fs[ix(@fs.length)]
  end
  
  def random_local()
    "@#{@vs[ix(@fs.length)]}".to_sym
  end
  
  # Obtains a random variable name
  def random_variable()
    @vs[ix(@fs.length)]
  end
  
  def random_op()
    @os[ix(@os.length)]
  end
  
  def random_num()
    @ns[ix(@ns.length)]
  end
  
  def random_exp(dice=random_local)
    @ss[ix(@ss.length)].call(random_op, random_local, dice, random_local, random_num)
  end
  
end

# Moves functions around, prunes pre-existing junk.
class Adam < SexpProcessor
  
  def initialize
    super && self.strict = self.require_empty = ! self.auto_shift_type = true
  end
  
  def rewrite_call(exp)
    head = exp.shift
    rotate_commutatitive(exp).unshift(head)
  end
  
  # Rearrange argument order
  def shift_arguments; end
  
  # Move a function call inline
  def inline; end
  
  # Make sequence a function
  def outline; end
  
  # Reshapes commutatitive statements
  # x = 5 + 10 #=> x = 10 + 5
  def rotate_commutatitive(exp)
    if commutatitve(exp)
      (exp[2][1], exp[0] = exp[0], exp[2][1])
    end
    
    exp
  end
  
  # Looks cryptic, I know.  This looks for s-expressions with commutatitive
  # operations.
  #
  # exp / Q?{...} -> convenience method for creating an s-expression pattern matcher.
  # s(_, :+, _)   -> pattern #1 – anything (plus) anything else
  # s(_, :*, _)   -> pattern #2 – anything (times) anything else
  # !(...).empty? -> result is not empty
  def commutatitve(exp)
    !(exp / Q?{ any( s(_,:*,_) ) }).empty?
  end
  
  # Remove junk methods
  def rewrite_defs(exp)
    # The 3rd item in the element is the function name -- strip out prev. junk methods.
    if [:j1, :j2, :j3, :j4].include?(exp[2])
      return s(:nil)
    else
      exp
    end
  end

  def rewrite_lasgn(exp)
    if [:v1, :v2, :v3, :v4].include?(exp[1])
      return s(:nil)
    else
      exp
    end
  end
  
  def rewrite_iasgn(exp)
    if [:@v1, :@v2, :@v3, :@v4].include?(exp[1])
      return s(:nil)
    else
      exp
    end
  end
  
  # Reorders independent statements.  It turns out that this will even re-arrange
  # the order of methods since method definitions occur in blocks.
  def rewrite_block(exp)
    # Take the leading atom (:block) of the s-expression, we'll put it back
    # on before returning.  This way, the rotate independent code doesn't
    # have to worry about the leading atom for the original sexp.
    atom = exp.shift
    
    # Preserve the return statement – in ruby the last statement
    # is always the returned value.  It cannot necessarily be
    # re-ordered.
    return_exp = exp.pop
    
    # Rotate the remaining statements and then replace the original
    # atom and return s-expressions.
    rotate_independent(exp).unshift(atom).push(return_exp)
  end
  
  # A recursive way of changing the order of execution in a statement.  Put
  # the statement at the
  def rotate_independent(exp)
    
    # Base case, a single line expression cannot be re-arranged.
    return exp if exp.length <= 1
    
    # Re-order two independent statetements
    if independent(exp[-1], exp[-2]) and independent(exp[-2], exp[-1])
      exp[-1], exp[-2] = exp[-2], exp[-1]
    end
    
    # Preserve the last statement
    last_exp = exp.pop
    
    # Attempt to re-order the rest
    return rotate_independent(exp).push(last_exp)
  end
  
  # Using pattern matchinf for s-expressions, figure out if 
  # s1 assigns to anything used by s2.  If not, then match
  # will be empty – and s1/s2 are therefore independent.
  def independent(s1, s2)
    atom = s1 / Q? { s(:lasgn, _ % 'atom', _) }
    return if atom.empty?
    match = s2 / Q? { include(atom.first["atom"].to_sym) }
    match.empty?
  end
  
end
