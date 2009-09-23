module SDES
  class Input < Struct.new(:file_name, :student_name, :key, :content, :mode)
    include SDES::Utility
    include SDES::Key
  
    def initialize(path)
      # we skip lines 4 and 5 on purpose
      f = open(path)
      line = f.readlines
      f.close
    
      self.file_name = line[0].chomp
      self.student_name = line[1].chomp
      self.mode = line[2].chomp
      self.key = line[3].chomp
      self.content = line[6]
    end
  
    def encrypt?
      self.mode && self.mode.downcase == "e"
    end
  
    def decrypt?
      self.mode && self.mode.downcase == "d"
    end
  
    def encrypt
      warn "Encrypting a file that specfied decryption." if decrypt?
      SDES::Utility.encrypt(self.content, self.key)
    end
  
    def decrypt
      warn "Decrypting a file that specfied encryption." if encrypt?
      SDES::Utility.decrypt(self.content, self.key)
    end
  
  end
end
