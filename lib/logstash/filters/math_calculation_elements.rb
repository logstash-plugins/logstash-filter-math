# encoding: utf-8
require "logstash/util/loggable"

module LogStash module Filters
  module MathCalculationElements
    REGISTER_REFERENCE_RE = /^MEM\[(\d+)]$/

    def self.build(reference, position)
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
          RegisterElement.new(reference, position, match[1].to_i)
        else
          FieldElement.new(reference, position)
        end
      else
        nil
      end
    end

    class RegisterElement
      # supports `get` and `set`
      def initialize(reference, position, index)
        @reference = reference
        @position = position
        @index = index
        @description = (position == 3 ? "#{@index}" : "operand #{@position}").prepend("register ").concat(": '#{@reference}'")
      end

      def key
        @index
      end

      def literal?
        false
      end

      def set(value, event_register_context)
        # raise usage error if called when position != 3 ??
        event_register_context.set(self, value)
      end

      def get(event_register_context)
        event_register_context.get(self) #log warning if nil
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

      def key
        @field
      end

      def literal?
        false
      end

      def set(value, event_register_context)
        event_register_context.set(self, value)
      end

      def get(event_register_context)
        value = event_register_context.get(self)
        if value.nil?
          logger.warn("field not found", "field" => @field, "event" => event_register_context.event.to_hash)
          return nil
        end
        case value
        when Numeric
          value
        when LogStash::Timestamp, Time
          value.to_f
        else
          logger.warn("field value is not numeric or time", "field" => @field, "value" => value, "event" => event_register_context.event.to_hash)
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

      def key
        nil
      end

      def literal?
        true
      end

      def get(event_register_context = nil)
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
