# encoding: utf-8
require "logstash/util/loggable"

module LogStash module Filters
  module MathCalulationElements
    REGISTER_REFERENCE_RE = /^R\[(\d+)]$/

    def self.build(reference, position, register)
      case reference
      when Numeric
        if position == 3
          # literal reference for result element
          nil
        else
          LiteralElement.new(reference, position)
        end
      when String
        match = REGISTER_REFERENCE_RE.match(reference)
        if match
          RegisterElement.new(reference, position, match[1].to_i, register)
        else
          FieldElement.new(reference, position)
        end
      else
        nil
      end
    end

    class RegisterElement
      # supports `get` and `set`
      def initialize(reference, position, index, register)
        @reference = reference
        @position = position
        @index = index
        @register = register
        @description = (position == 3 ? "#{@index}" : "operand #{@position}").prepend("register ").concat(": '#{@reference}'")
      end

      def literal?
        false
      end

      def set(value, event)
        # raise usage error if called when position != 3 ??
        @register[@index] = value
      end

      def get(event)
        @register[@index] #log warning if nil
      end

      def inspect
        "\"#{@description}\""
      end

      def to_s
        @description
      end
    end

    class FieldElement
      include LogStash::Util::Loggable
      # supports `get` and `set`
      def initialize(field, position)
        @field = field
        @position = position
        @description = (position == 3 ? "result" : "operand #{@position}").prepend("event ").concat(": '#{@field}'")
      end

      def literal?
        false
      end

      def set(value, event)
        event.set(@field, value)
      end

      def get(event)
        value = event.get(@field)
        if value.nil?
          logger.warn("field not found", "field" => @field, "event" => event.to_hash)
          return nil
        end
        case value
        when Numeric
          value
        when LogStash::Timestamp, Time
          value.to_f
        else
          logger.warn("field value is not numeric or time", "field" => @field, "value" => value, "event" => event.to_hash)
          nil
        end
      end

      def inspect
        "\"#{@description}\""
      end

      def to_s
        @description
      end
    end

    class LiteralElement
      # does not support `set`
      def initialize(literal, position)
        @literal = literal
        @position = position
      end

      def literal?
        true
      end

      def get(event = nil)
        @literal
      end

      def inspect
        "\"operand #{@position}: #{@literal.inspect}\""
      end

      def to_s
        inspect
      end
    end
  end
end end
