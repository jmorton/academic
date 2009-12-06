# -- awake
# [ ] read SDES
# [ ] decrypt mutator
# [ ] mutate and replace SDES
# [ ] payload: increment file
# [ ] encrypt mutator
# -- sleep

def decrypt(path)
  require "mutator"
  puts "todo"
end

def encrypt(path)
  puts "todo"
end

# Convert code into an AST, muck it up, generate ruby
def mutated(source)
  puts "mutating"
  Ruby2Ruby.new.process(
    Eve.new.rewrite(
      Adam.new.rewrite(
        RubyParser.new.process(source))))
end

# Read and replace a source file with a mutation
def replace(path)
  original = open(path,"r") { |f| f.lines.map.join }
  variant = yield(original)
  open(path,"w") { |f| f.puts(variant) }
end

# The bootstrap.
decrypt("mutator.rb")
replace("encrypt.rb") { |code| mutated(code) }
encrypt("mutator.rb")
