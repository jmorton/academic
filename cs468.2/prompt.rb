require "environment"
require "highline/import"
require "kernel"

include Cap

def list(*subjects)
  subjects.each do |s|
    puts(s)
  end
end

# Initial setup

s1 = Subject.new("red")
s2 = Subject.new("blue")
s3 = Subject.new("green")

o1 = Cap::Object.new("file")
o2 = Cap::Object.new("printer")
o3 = Cap::Object.new("phone")
  
@k = Cap::Kernel.new

c1 = @k.grant(s1,o1)
c2 = @k.grant(s2,o2)
c3 = @k.grant(s3,o3)

@users = {
  :red => s1,
  :blue => s2,
  :green => s3
}

@objects = {
  :file => o1,
  :phone => o3,
  :printer => o2
}

t1 = c1.transfer(s2,Right::R)

# list(s1, s2, s3)

# @h.say "#{@k.verify(s2,t1)}"

loop do
  choose do |m|
    m.shell  = true
    m.header = "Capability Manager"
    m.prompt = "What do you want to do? "
    
    m.choice(:all, "list all subjects and capabilities") do |command, details|
      list(@users.values)
    end
    
    m.choice(:list, "list a specific subject's capabilities") do |command, details|
      begin
        list(@users[details.to_sym])
      rescue
        "no user with ID of '#{details}' found."
      end
    end
    
    m.choice(:transfer) do |command, details|
    # owner, new owner, cap
    # transfer red blue 
    end
    
    m.choice(:modify) do |command, details|
    # changes a capability
    end
    
    m.choice(:verify) do |command, details|
    end
    
    m.choice(:exit) { exit }
  end
end

