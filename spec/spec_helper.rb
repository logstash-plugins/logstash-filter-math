# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"

ENV["LOG_AT"].tap do |level|
  LogStash::Logging::Logger::configure_logging(level) unless level.nil?
end
