require "environment"
require "highline"
require "kernel"

include Cap

# Initial setup

@k = Cap::Kernel.new

s1 = Subject.new
s2 = Subject.new
s3 = Subject.new

o1 = Cap::Object.new
o2 = Cap::Object.new
o3 = Cap::Object.new
  
c1 = @k.grant(s1,o1)
c2 = @k.grant(s2,o2)
c3 = @k.grant(s3,o3)


h = HighLine.new

h.say "Hello"

t1 = c1.transfer(s2,Right::R)

h.say "#{@k.verify(s2,t1)}"
