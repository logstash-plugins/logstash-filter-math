# encoding: utf-8

require "logstash/namespace"
require "logstash/filters/base"

require_relative "math_functions"
require_relative "math_calculation_elements"

# Do various simple math functions
# Configuration:
# filter {
#   math {
#     calculate => [
#         [ "+", "a_field1", "a_field2", "a_target" ],   # a + b => target
#         [ "-", "b_field1", "b_field2", "b_target" ],   # a - b => target
#         [ "/", "c_field1", "c_field2", "c_target" ],   # a / b => target
#         [ "*", "d_field1", "d_field2", "d_target" ]    # a * b => target
#     ]
#   }
# }
# Multiple calculations can be executed with one call
#
# Sequence of processing is as they are listed, so processing of just-generated fields is
# possible as long as it is done in the correct sequence.
#
# Works with float and integer values

module LogStash module Filters class Math < LogStash::Filters::Base
  # TODO: Add support for unitary functions like abs and negation (-),
  #       these would have one operand and may or may not have a target.
  #       Add support for constants as either operand, e.g. seconds to millis, 100 / N
  #       Add support for conversions: distance(mi <-> km)
  #       Add support for percent change
  config_name "math"

  # fields - second subtracted from the first
  config :calculate, :validate => :array, :required => true

  public

  def register
    functions = {}
    [
      [MathFunctions::Add.new, '+', 'add', 'plus'],
      [MathFunctions::Subtract.new, '-', 'subtract'],
      [MathFunctions::Multiply.new, '*', 'times', 'multiply'],
      [MathFunctions::Power.new, '**', '^', 'to the power of'],
      [MathFunctions::Divide.new, '/', 'divide'],
      [MathFunctions::Modulo.new, 'mod', 'modulo'],
      [MathFunctions::FloatDivide.new, 'fdiv', 'float divide']
    ].each do |list|
      value = list.shift
      list.each{|key| functions[key] = value}
    end

    # Do some sanity checks that calculate is actually an array-of-arrays, and that each calculation (sub-array)
    # is exactly 4 fields and the first field is a valid calculation operator name.
    @calculate_copy = []
    all_function_keys = functions.keys
    @register = []
    calculate.each do |calculation|
      if calculation.size != 4
        raise LogStash::ConfigurationError, I18n.t(
          "logstash.runner.configuration.invalid_plugin_register",
          :plugin => "filter",
          :type => "math",
          :error => "Invalid number of elements in a calculation setting: expected 4, got: #{calculation.size}. You specified: #{calculation}"
        )
      end
      function_key, operand1, operand2, target = calculation
      if !all_function_keys.include?(function_key)
        raise LogStash::ConfigurationError, I18n.t(
          "logstash.runner.configuration.invalid_plugin_register",
          :plugin => "filter",
          :type => "math",
          :error => "Invalid first element of a calculation: expected one of #{all_function_keys.join(',')}, got: #{function_key}. You specified: #{calculation.join(',')}"
        )
      end
      function = functions[function_key]

      left_element = MathCalulationElements.build(operand1, 1, @register)
      right_element = MathCalulationElements.build(operand2, 2, @register)
      if right_element.literal?
        lhs = left_element.literal? ? left_element.get : 1
        warning = function.invalid?(lhs, right_element.get)
        unless warning.nil?
          raise LogStash::ConfigurationError, I18n.t(
            "logstash.runner.configuration.invalid_plugin_register",
            :plugin => "filter",
            :type => "math",
            :error => "Numeric literals are specified as in the calculation but the function invalidates with '#{warning}'. You specified: #{calculation.join(',')}"
          )
        end
      end
      result_element = MathCalulationElements.build(target, 3, @register)
      @calculate_copy << [function, left_element, right_element, result_element]
    end
    if @calculate_copy.last.last.is_a?(MathCalulationElements::RegisterElement)
      raise LogStash::ConfigurationError, I18n.t(
        "logstash.runner.configuration.invalid_plugin_register",
        :plugin => "filter",
        :type => "math",
        :error => "The final target is a Register, the overall calculation result will not be set in the event"
      )
    end
  end

  def filter(event)
    event_changed = false # can exit if none of the calculations are are suitable
    @register.clear # don't carry over register results from one event to the next.
    @calculate_copy.each do |function, left_element, right_element, result_element|
      logger.debug("executing", "function" => function.name, "left_field" => left_element, "right_field" => right_element, "target" => result_element)
      # TODO add support for automatic conversion to Numeric if String
      operand1 = left_element.get(event)
      operand2 = right_element.get(event)
      # allow all the validation warnings to be logged before we skip to next
      next if operand1.nil? || operand2.nil?
      next if function.invalid?(operand1, operand2, event)

      result = function.call(operand1, operand2)
      result_element.set(result, event)
      logger.debug("calculation result stored", "function" => function.name, "target" => result_element, "result" => result)
      event_changed = true
    end
    return unless event_changed
    filter_matched(event)
  end
end end end


