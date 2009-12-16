class Immune
end
module A
  A1 = "Sauce"
  module B
    def self.j1(*args)
      @v3 ||= 8
      @v2 ||= 6
      (@v2 + @v3)
    end
    def self.j2(*args)
      @v1 ||= 2
      @v4 ||= 0
      (@v4 + @v1)
    end
    def self.j3(*args)
      @v3 ||= 5
      @v2 ||= 3
      (@v2 + @v3)
    end
    def self.j4(*args)
      @v1 ||= 8
      @v4 ||= 6
      (@v4 + @v1)
    end
    # do nothing
    # do nothing
    # do nothing
    # do nothing
    def self.foo(x, y)
      v3 = j4
      v1 = j2
      # do nothing
      # do nothing
      z = 1
      x = (5 + x)
      y = (y * 5)
      return (y + x)
    end
    B1 = "Bomber"
    def self.bar(a, b)
      v3 = j4
      v1 = j2
      # do nothing
      # do nothing
      x = foo(a, b)
      y = foo(a, b)
      z = foo(x, y)
      return (1 + (1 - (y + x)))
    end
  end
end
