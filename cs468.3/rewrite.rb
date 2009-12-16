#
# [x] read SDES
# [x] decrypt mutator
# [x] mutate and replace SDES
# [x] encrypt and replace mutator
#
require "mutator_original" # to include mutator without decrypting it.
#

require "encrypt"

def decrypt(text)
  SDES::Utility.decrypt(text, "1100100001")
end

def encrypt(text)
  SDES::Utility.encrypt(text, "1100100001")
end

# Convert code into an AST, muck it up, generate ruby
def mutate(source)
  Ruby2Ruby.new.process(
    Eve.new.rewrite(
      Adam.new.rewrite(
        RubyParser.new.process(source))))
end

# Read and replace a source file with a mutation
def replace(path)
  original = open(path,"r") { |f| f.lines.map.join }
  modified = yield(original)
  open(path,"w") { |f| f.puts(modified) }
end

replace("encrypt.rb") do |code|
  decrypt(open("mutator.rb","r").first)
  mutate(code)
end

replace("test.rb") do |code|
  decrypt(open("mutator.rb","r").first)
  mutate(code)
end

# replace("mutator.rb") do |m|
#   encrypt(open("mutator_original.rb","r").lines.map.join)
# end