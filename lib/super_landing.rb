require 'json'
require 'rest-client'
require "active_support/core_ext/module/delegation"
require "super_landing/version"
require "super_landing/client"
require "super_landing/api/base"
require "super_landing/api/order"
require "super_landing/api/statistic_items"
require "super_landing/api/response/base"
require "super_landing/api/response/order"
require "super_landing/api/response/statistic_items"

module SuperLanding
  BASE_URL = "https://www.super-landing.com/api"
end
