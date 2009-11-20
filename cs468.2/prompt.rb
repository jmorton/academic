require "environment"
require "highline/import"
require "kernel"

include Cap

# Initial setup

s =[ Subject.new("red", Clearance::TopSecret),
     Subject.new("purple", Clearance::Secret),
     Subject.new("green", Clearance::Secret),
     Subject.new("gold", Clearance::Confidential),
     Subject.new("blue", Clearance::TopSecret),
     Subject.new("yellow", Clearance::TopSecret) ]

o = [ Cap::Object.new("printer_red", Clearance::TopSecret),
      Cap::Object.new("printer_purple", Clearance::Secret),
      Cap::Object.new("network_card_green", Clearance::Secret),
      Cap::Object.new("network_card_gold", Clearance::Confidential),
      Cap::Object.new("disk_blue", Clearance::TopSecret),
      Cap::Object.new("disk_yellow", Clearance::TopSecret) ]

# Initialize the kernel with default subjects/objects

@k = Cap::Kernel.new

@users = {}
@objects = {}

s.zip(o).each do |subject, object|
  @k.grant(subject, object)
  @users[subject.name] = subject
  @objects[object.name] = object
end
    
loop do
  choose do |m|
    m.shell  = true
    m.header = "Capability Manager"
    m.prompt = "What do you want to do? "
    
    m.choice(:all, "list all subjects and capabilities") do |command, details|
      @users.values.each do |s|
        puts(s)
      end
    end
    
    m.choice(:list, "list a specific subject's capabilities") do |command, details|
      begin
        puts @users[details]
      rescue
        "no user with ID of '#{details}' found."
      end
    end
    
    m.choice(:transfer) do |command, details|
      begin
        transfer_pattern = /(\w+) (\w+) (\w+) ([RW]+)/
      
        # Assigns each match to a variable – nice short hand.
        owner_id, recipient_id, object_id, rights_id = details.scan(transfer_pattern).first
      
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
          c = capability.transfer(recipient, rights)
          say "Ok: #{c}"
        end
      rescue
        say("try this instead: 'transfer <owner> <recipient> <object> <rights>")
      end
    end
    
    m.choice(:modify) do |command, details|
      modify_pattern = /([RW]+) (\w+) (\w+)/
            
      rights_id, subject_id, object_id = details.scan(modify_pattern).first

      begin
        subject = @users[subject_id]
        capability = subject.capabilities[object_id]
        capability.right = rights_id
        say("Capability modified – it should no longer be valid.")
        say("valid #{subject_id} #{object_id}: #{@k.verify(subject, capability)}")
      rescue Exception => e
        say e
        say("try this instead: 'modify <rights> <subject> <object>")
        say("subject = #{subject_id}")
      end
    end
    
    m.choice(:valid) do |command, details|
      begin
        valid_pattern = /(\w+) (\w+)/
      
        subject_id, object_id = details.scan(valid_pattern).first
      
        subject = @users[subject_id]
        capability = subject.capabilities[object_id]
      
        if subject.nil?
          say "nobody named '#{subject_id}' exists"
        elsif capability.nil?
          say "#{subject_id} does not have a capability token for the object '#{object_id}'"
        else
          say "#{@k.verify(subject, capability)}"
        end
      rescue
        say "False (an error occurred)."
      end
    end
    
    m.choice(:exit) { exit }
  end
end

