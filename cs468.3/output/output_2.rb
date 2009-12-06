module Oh
  module Yah
    def f1(x, *args)
      nop(@v2)
    end
    def f2(x, *args)
      @v2 = (@v2 ** @v1)
    end
    def f3(x, *args)
      nop(@v4)
    end
    def f4(x, *args)
      @v4 = (@v4 - @v3)
    end
    def foo(x, y)
      y = (5 * y)
      z = 1
      x = (x + 5)
      return (x + y)
    end
    # do nothing
    # do nothing
    # do nothing
    # do nothing
    def bar(a, b)
      x = foo(a, b)
      y = foo(a, b)
      return ((1 - (x + y)) + 1)
    end
    def nop(*args)
      a = "a"
      b = "b"
      @a
      @c = (@a + @b)
      return @c
    end
  end
end
