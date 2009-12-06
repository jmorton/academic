#
# author: Jon Morton
#
# = About
# A simplified and less secure version of DES.  This was implemented
# as part of my coursework for CS 468 at George Mason University. If
# you use this code commercially, you've made a wrong turn.
#
# = Important Notes
# 1. I did not take an object oriented approach to implementing the majority
# of the cryptographic functions (seen in sdes/key.rb and sdes/utility.rb)
# 2. The tables used by permutation and substitution functions are defined
# as class variables in sdes/tables.rb.
# 3. I've "monkey-patched" String, Fixnum, and Array.  Usually, this practice
# is discouraged unless you really know what you're doing (which I do) and
# this code would not be used in a large scale system anyhow.  Therefore, even
# though adding to the standard classes can make things complicated it does make
# the code far more expressive and readable.
#
# = References
# I did not read any other libraries to get ideas about how to implement this.
# I did seek out bit twiddling code for the circular shift operation. I did
# not use the code seen on http://en.wikipedia.org/wiki/Circular_shift verbatim.
#

require 'sdes/tables'
require 'sdes/key'
require 'sdes/utility'
require 'sdes/io'
require 'sdes/extensions'
