require 'selenium-webdriver'
require './edge_test'
require 'date'
require 'colorize'

module QA
  module TestHelpers
    def wait
      Selenium::WebDriver::Wait.new(timeout: 15)
    end
  end
end

RSpec.configure do |config|
  config.include(QA::TestHelpers)
end
