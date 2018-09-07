# encoding: utf-8

module LogStash module Filters
  class Storage

    attr_reader :event, :register

    def initialize(event)
      @event = event
      @register = []
    end
  end
end end
