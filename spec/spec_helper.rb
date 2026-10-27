$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start { add_filter "/spec/" }
end

require "minitest/autorun"
require "minitest/mock"
require "super_landing"
require 'json'
require_relative "support/fake_server"
