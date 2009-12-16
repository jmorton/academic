class Immune
end
module A
  A1 = "Sauce"
  module B
    B1 = "Bomber"
    def self.foo(x, y)
      y = (5 * y)
      z = 1
      x = (x + 5)
      return (x + y)
    end
    def self.bar(a, b)
      x = foo(a, b)
      y = foo(a, b)
      return ((1 - (x + y)) + 1)
    end
  end
end
