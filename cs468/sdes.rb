#
# author: Jon Morton
#
# = About
# A simplified and less secure version of DES.  This was implemented
# as part of my coursework for CS 468 at George Mason University. If
# you use this code commercially, you're making a huge mistake.
#
# = Important Notes
# 1. I did not take an object oriented approach to implementing the majority
# of the cryptographic functions.
# 2. I've "monkey-patched" String, Fixnum, and Array.  Usually, this practice
# is discouraged unless you really know what you're doing (which I do) and
# this code should not be used in a large scale system.  Therefore, even though
# adding to the standard classes can make things complicated it makes the code
# far more expressive.
#


require 'sdes/tables'
require 'sdes/key'
require 'sdes/utility'
require 'sdes/input'
require 'sdes/extensions'
