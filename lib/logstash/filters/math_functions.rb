# encoding: utf-8
require "logstash/util/loggable"

module LogStash module Filters
  module MathFunctions
    module DivByZeroValidityCheck
      def invalid?(op1, op2, event = nil)
        if op2.zero?
          warning = "a divisor of zero is not permitted"
          if event
            # called from filter so log
            logger.warn(warning, "operand 1" => op1, "operand 2" => op2, "event" => event.to_hash)
            return true
          else
            # called from register don't log return warning for the error that is raised
            return warning
          end
        end
        nil
      end
    end

    module NoValidityCheckNeeded
      def invalid?(op1, op2, event = nil)
        nil
      end
    end

    class Add
      include NoValidityCheckNeeded

      def name
        "add"
      end

      def call(op1, op2)
        op1 + op2
      end
    end

    class Subtract
      include NoValidityCheckNeeded

      def name
        "subtract"
      end
      def call(op1, op2)
        op1 - op2
      end
    end

    class Multiply
      include NoValidityCheckNeeded

      def name
        "multiply"
      end

      def call(op1, op2)
        op1 * op2
      end
    end

    class Power
      include LogStash::Util::Loggable

      def name
        "power"
      end

      def call(op1, op2)
        op1 ** op2
      end

      def invalid?(op1, op2, event = nil)
        if op1.is_a?(Numeric) && op1.negative? && !op2.integer?
          warning = "raising a negative number to a fractional exponent results in a complex number that cannot be stored in an event"
          if event
            # called from filter so log
            logger.warn(warning, "operand 1" => op1, "operand 2" => op2, "event" => event.to_hash)
            return true
          else
            # called from register don't log return warning for the error that is raised
            return warning
          end
        end
        nil
      end
    end

    class Divide
      include LogStash::Util::Loggable
      include DivByZeroValidityCheck

      def name
        "divide"
      end

      def call(op1, op2)
        op1 / op2
      end
    end

    class FloatDivide
      include LogStash::Util::Loggable
      include DivByZeroValidityCheck

      def name
        "float_divide"
      end

      def call(op1, op2)
        op1.fdiv(op2)
      end
    end

    class Modulo
      include LogStash::Util::Loggable
      include DivByZeroValidityCheck

      def name
        "modulo"
      end

      def call(op1, op2)
        op1 % op2
      end
    end
  end
end end
