# encoding: utf-8

module LogStash module Filters
  class EventRegisterContext

    attr_reader :event, :register

    def initialize(event)
      @event = event
      @register = []
    end

    def get(element)
      case element
      when MathCalculationElements::RegisterElement
        @register[element.key]
      when MathCalculationElements::FieldElement
        @event.get(element.key)
      end
    end

    def set(element, value)
      case element
      when MathCalculationElements::RegisterElement
        @register[element.key] = value
      when MathCalculationElements::FieldElement
        @event.set(element.key, value)
      end
    end
  end
end end
