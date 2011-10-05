#
# [x] read SDES
# [x] decrypt mutator
# [x] mutate and replace SDES
# [x] encrypt and replace mutator
#
# require "mutator_original" # to include mutator without decrypting it.
#

require "encrypt"

def decrypt(text)
  SDES::Utility.decrypt(text, "1100100001")
end

def encrypt(text)
  SDES::Utility.encrypt(text, "1100100001")
end

# Convert code into an AST, muck it up, generate ruby... this will not run
# if the mutator is not first decrypted and loaded.
def mutate(source)
  Ruby2Ruby.new.process(
    Eve.new.rewrite(
      Adam.new.rewrite(
        RubyParser.new.process(source))))
end

# Read and replace a source file with the value returned by yield()...
# Just a handy helper function.
def replace(path)
  original = open(path,"r") { |f| f.lines.map.join }
  modified = yield(original)
  open(path,"w") { |f| f.puts(modified) }
end

# ONLY NEEDED DURING DEVELOPMENT TO UPDATE THE ENCRYPTED MUTATOR CODE.
# replace("mutator.rb") do |m|
#   encrypt(open("mutator_original.rb","r").lines.map.join)
# end

# Yes, this actually replaces the encrypted file...
replace("encrypt.rb") do |code|
  # This dynamically loads the decrypted code...
  puts "Reading encrypted mutator code..."
  eval(decrypt(open("mutator.rb","r").first))
  puts "Mutating SDES code..."
  mutate(code)
end

# This is a litmus test, the code in test.rb is modified just like encrypt.rb...
# Some of the changes in encrypt.rb will be very hard to spot... this file
# makes it abundantly obvious.
replace("test.rb") do |code|
  mutate(code)
end

puts "Done."
