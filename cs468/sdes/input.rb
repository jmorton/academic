module SDES
  class Input < Struct.new(:file_name, :student_name, :key, :content, :mode)
  
    def initialize(path)
      # we skip lines 4 and 5 on purpose because this implementation
      # does not need to support any streaming ciphers
      f = open(path)
      line = f.readlines
      f.close
    
      self.file_name = line[0].chomp
      self.student_name = line[1].chomp
      self.mode = line[2].chomp
      self.key = line[3].chomp
      self.content = line[6]
    end
  
    def process!
      encrypt or decrypt or raise "Could not encrypt or decrypt #{self.file_name}"
    end
  
    def encrypt?
      self.mode && self.mode.downcase == "e"
    end
  
    def decrypt?
      self.mode && self.mode.downcase == "d"
    end
  
    def encrypt
      encrypt? && SDES::Utility.encrypt(self.content, self.key)
    end
  
    def decrypt
      decrypt? && SDES::Utility.decrypt(self.content, self.key)
    end
  
  end
end
