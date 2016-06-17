require 'selenium-webdriver'
require 'byebug'
require 'browsermob-proxy'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

class EdgeTest
  include Capybara::DSL
  attr_accessor :url

  def initialize(url)
    @url = url
    EdgeTest.proxy.new_har("#{url}")
  end

  def self.run
    server.start
    setup_drivers
  end

  # def record_requests
  #   proxy.new_har("#{url}")
  # end

  def self.stop
    proxy.close
  end

  def self.server
    @@server ||= BrowserMob::Proxy::Server.new("./browsermob-proxy-2.1.1/bin/browsermob-proxy")
  end

  def self.setup_drivers
    chromedriver_path = "./chromedriver"
    Selenium::WebDriver::Chrome.driver_path = chromedriver_path
    selenium_proxy = Selenium::WebDriver::Proxy.new(:http => proxy.selenium_proxy.http)
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(:proxy => selenium_proxy)

    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['general.useragent.override'] = "iPhone"

    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new(app, :browser => :chrome, :desired_capabilities => caps)
    end

    Capybara.register_driver :iphone do |app|
      Capybara::Selenium::Driver.new(app, :profile => profile, :desired_capabilities => caps)
    end

    Capybara.current_driver = :chrome
  end


  def self.proxy
    @@proxy ||= server.create_proxy
  end

  def har
    @har ||= EdgeTest.proxy.har
  end

  def har_entries
    har.entries
  end

  def edge_requests
    @edge_requests ||= har_entries.select{|e| e.request.url.include?('edge') }
  end

  def n_requests
    @n_requests ||= edge_requests.select{|e| e.request.url.include?('/n?')}
  end

  def t_requests
    @t_requests ||= edge_requests.select{|e| e.request.url.include?('/t?')}
  end

  def event_requests
    @event_requests ||= edge_requests.select{|e| e.request.url.include?('/event?')}
  end

  def n_request
    @n_request ||= n_requests.first
  end

  def query_string
    @query_string ||= n_request.request.query_string if n_request
  end
end
