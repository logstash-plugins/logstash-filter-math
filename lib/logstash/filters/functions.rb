# encoding: utf-8

module Functions
  module DivByZeroCheck
    def invalid?(op1, op2)
      if op2.zero?
        return "a divisor of zero is not permitted"
      end
      nil
    end
  end
  module NoDivByZeroCheck
    def invalid?(op1, op2)
      nil
    end
  end

  class Add
    include NoDivByZeroCheck

    def name
      "add"
    end

    def call(op1, op2)
      op1 + op2
    end
  end

  class Subtract
    include NoDivByZeroCheck

    def name
      "subtract"
    end
    def call(op1, op2)
      op1 - op2
    end
  end

  class Multiply
    include NoDivByZeroCheck

    def name
      "multiply"
    end

    def call(op1, op2)
      op1 * op2
    end
  end

  class Power
    def name
      "power"
    end

    def call(op1, op2)
      op1 ** op2
    end

    def invalid?(op1, op2)
      if op1.negative? && !op2.integer?
        return "raising a negative number to a fractional exponent results in a complex number that cannot be stored in an event"
      end
      nil
    end
  end

  class Divide
    include DivByZeroCheck

    def name
      "divide"
    end

    def call(op1, op2)
      op1 / op2
    end
  end

  class FloatDivide
    include DivByZeroCheck

    def name
      "float_divide"
    end

    def call(op1, op2)
      op1.fdiv(op2)
    end
  end

  class Modulo
    include DivByZeroCheck

    def name
      "modulo"
    end

    def call(op1, op2)
      op1 % op2
    end
  end
end
