module Oh
  module Yah
    def f1(x, *args)
      nop(@v4)
    end
    def f2(x, *args)
      @v4 = (@v4 - @v3)
    end
    def f3(x, *args)
      nop(@v2)
    end
    def f4(x, *args)
      @v2 = (@v2 ** @v1)
    end
    def foo(x, y)
      z = 1
      x = (5 + x)
      y = (y * 5)
      return (y + x)
    end
    # do nothing
    # do nothing
    # do nothing
    # do nothing
    def bar(a, b)
      y = foo(a, b)
      x = foo(a, b)
      return (1 + (1 - (y + x)))
    end
    def nop(*args)
      b = "b"
      a = "a"
      @a
      @c = (@b + @a)
      return @c
    end
  end
end