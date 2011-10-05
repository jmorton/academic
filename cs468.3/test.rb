class Immune
end
module A
  A1 = "Sauce"
  module B
    def self.j1(*args)
      @v4 ||= 10
      @v3 ||= 8
      (@v3 + @v4)
    end
    def self.j2(*args)
      @v2 ||= 4
      @v1 ||= 2
      (@v1 + @v2)
    end
    def self.j3(*args)
      @v4 ||= 7
      @v3 ||= 5
      (@v3 + @v4)
    end
    def self.j4(*args)
      @v2 ||= 10
      @v1 ||= 8
      (@v1 + @v2)
    end
    # do nothing
    # do nothing
    # do nothing
    # do nothing
    B1 = "Bomber"
    def self.foo(x, y)
      v4 = j1
      v2 = j3
      # do nothing
      # do nothing
      x = (x + 5)
      y = (5 * y)
      z = 1
      return (x + y)
    end
    def self.bar(a, b)
      v4 = j1
      v2 = j3
      # do nothing
      # do nothing
      x = foo(a, b)
      y = foo(a, b)
      return ((1 - (x + y)) + 1)
    end
  end
end
