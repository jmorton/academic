require "environment"
require "highline"
require "kernel"

include Cap

@h = HighLine.new
@k = Cap::Kernel.new
@users = {}

def list(*subjects)
  subjects.each do |s|
    puts(s)
    puts(s.capabilities)
  end
end

# Initial setup

s1 = Subject.new("red")
s2 = Subject.new("blue")
s3 = Subject.new("green")

o1 = Cap::Object.new("file")
o2 = Cap::Object.new("printer")
o3 = Cap::Object.new("phone")
  
c1 = @k.grant(s1,o1)
c2 = @k.grant(s2,o2)
c3 = @k.grant(s3,o3)

t1 = c1.transfer(s2,Right::R)

list(s2)

# @h.say "#{@k.verify(s2,t1)}"
