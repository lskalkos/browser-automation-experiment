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
    chromedriver_path = "./chromedriver"
    Selenium::WebDriver::Chrome.driver_path = chromedriver_path
  end

  def run
    server.start
    setup_driver
    proxy.new_har("#{url}")
  end

  def stop
    proxy.close
  end

  def server
    @server ||= BrowserMob::Proxy::Server.new("./browsermob-proxy-2.1.1/bin/browsermob-proxy", log: true)
  end

  def setup_driver
    selenium_proxy = Selenium::WebDriver::Proxy.new(:http => proxy.selenium_proxy.http)
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(:proxy => selenium_proxy)

    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new(app, :browser => :chrome, :desired_capabilities => caps)
    end

    Capybara.current_driver = :chrome
  end


  def proxy
    @proxy ||= server.create_proxy
  end

  def har
    @har ||= proxy.har
  end

  def temp_file
    "/tmp/test.har"
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
end
