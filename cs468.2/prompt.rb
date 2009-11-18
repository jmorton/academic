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
  "red" => s1,
  "blue" => s2,
  "green" => s3
}

@objects = {
  "file" => o1,
  "phone" => o3,
  "printer" => o2
}

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
      transfer_pattern = /(\w+) (\w+) (\w+) ([RW]+)/
      
      # Assigns each match to a variable – nice short hand.
      owner_id, recipient_id, object_id, rights_id = details.scan(transfer_pattern).first
      
      if owner_id.nil?
        say("try this instead: 'transfer <owner> <recipient> <object> <rights>")
      end
      
      owner = @users[owner_id]
      recipient = @users[recipient_id]
      capability = owner.capability_by_object_name(object_id)
      rights = eval("Right::#{rights_id.upcase}")
      
      if owner.nil?
        say "no subject named '#{owner_id}' exists"
      elsif recipient.nil?
        say "no subject named '#{recipient_id}' exists"
      elsif capability.nil?
        say "no capability for object named '#{object_id}' given to #{owner_id}"
      elsif rights.nil?
        say "could not understand right given by #{rights_id}"
      else
        capability.transfer(recipient, rights)
      end
    end
    
    m.choice(:valid) do |command, details|
      valid_pattern = /(\w+) (\w+)/
      
      subject_id, object_id = details.scan(valid_pattern).first
      
      subject = @users[subject_id]
      capability = subject.capability_by_object_name(object_id)
      
      if subject.nil?
        say "nobody named '#{subject_id}' exists"
      elsif capability.nil?
        say "#{subject_id} does not have a capability token for the object '#{object_id}'"
      else
        say "Valid? #{@k.verify(subject, capability)}"
      end
    end
    
    m.choice(:exit) { exit }
  end
end

