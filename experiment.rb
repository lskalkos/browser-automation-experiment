require 'selenium-webdriver'
require 'byebug'
require 'browsermob-proxy'

class EdgeTest
  attr_accessor :url

  def initialize(url)
    @url = url
    chromedriver_path = "./chromedriver"
    Selenium::WebDriver::Chrome.driver_path = chromedriver_path
  end

  def run
    server.start
    proxy.new_har("#{url}")
    driver.get(url)
    har.save_to("#{temp_file}")
    proxy.close
    driver.quit
    `har #{temp_file}`
  end

  def server
    @server ||= BrowserMob::Proxy::Server.new("./browsermob-proxy-2.1.1/bin/browsermob-proxy", log: true)
  end

  def driver
    selenium_proxy = Selenium::WebDriver::Proxy.new(:http => proxy.selenium_proxy.http)
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(:proxy => selenium_proxy)
    @driver ||= Selenium::WebDriver.for(:chrome, :desired_capabilities => caps)
  end


  def proxy
    @proxy ||= server.create_proxy
  end

  def har
    proxy.har
  end

  def temp_file
    "/tmp/test.har"
  end

  def har_entries
    har.entries
  end
end
