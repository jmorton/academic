module SDES
  class IO < Struct.new(:file_name, :student_name, :mode, :key, :cipher, :iv, :content)
  
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
      self.cipher = line[4].chomp
      self.iv = line[5].chomp
      self.content = line[6]
    end
  
    def process!
      result = encrypt || decrypt
      save!(result)
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
    
    def opposite_mode
      return "D" if self.encrypt? 
      return "E" if self.decrypt?
      return "?"
    end
  
    def output_path
      other_prefix = 'crypt-' if encrypt?
      other_prefix = 'plain-' if decrypt?
      self.file_name.gsub(/\w+\-/, other_prefix)
    end
    
    def self.process(filelist)
      paths = open(filelist).readlines
      saved = paths.map do |path|
        begin
          SDES::IO.new(path.chomp).process!
        rescue
          "Could not process '#{path}'"
        end
      end
      
      saved
    end
    
    protected
    
    def save!(result)
      open(output_path, "w").puts(output_path, student_name, opposite_mode, key, cipher, iv, result)
      output_path
    end
  
  end
end
