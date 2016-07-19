require 'selenium-webdriver'
require 'byebug'
require 'browsermob-proxy'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'
require 'uri'

class EdgeTest
  attr_accessor :url, :driver, :session
  attr_reader :page_ref
  COMPARISON_PARAMS = ["title", "url", "date", "pid", "tags", "channels", "authors"]
  EDGE_REGEX = Regexp.new("((http|https):\/\/)?edge.simplereach.com.*")
  ALL_JS_FILES_REGEX = Regexp.new(".*.js.*")

  def initialize(url, options = {})
    @url = url
    @driver = options[:driver] || :desktop_chrome
    @page_ref = options[:page_ref]
    Capybara.default_driver = driver
    EdgeTest.proxy.new_har("#{url}", capture_content: true)
    @session = Capybara::Session.new(driver)
  end

  def self.run(url)
    server.start
    whitelist_requests(url)
    setup_drivers
  end

  def self.whitelist_requests(url)
    proxy.whitelist([EDGE_REGEX, url_pattern_to_whitelist(url), ALL_JS_FILES_REGEX], 404)
  end

  def self.url_pattern_to_whitelist(url)
    host = URI.parse(url).host
    formatted_host = host.start_with?('www.') ? host[4..-1] : host
    Regexp.new("((http|https):\/\/)?(www.)?(mobile.|m.)?#{formatted_host}.*")
  end
  
  def self.stop
    proxy.clear_whitelist
    proxy.close
  end

  def self.server
    @@server ||= BrowserMob::Proxy::Server.new("./browsermob-proxy-2.1.1/bin/browsermob-proxy")
  end

  def self.setup_drivers
    chromedriver_path = "./chromedriver"
    Selenium::WebDriver::Chrome.driver_path = chromedriver_path

    Capybara.register_driver :desktop_chrome do |app|
      Capybara::Selenium::Driver.new(app, :browser => :chrome, :desired_capabilities => selenium_desktop_capabilities)
    end

    Capybara.register_driver :mobile_chrome do |app|
      Capybara::Selenium::Driver.new(app, :browser => :chrome, :desired_capabilities => selenium_mobile_capabilities)
    end

    Capybara.default_driver = :desktop_chrome
  end


  def self.proxy
    @@proxy ||= server.create_proxy
  end

  def self.selenium_webdriver_proxy
    @@selenium_webdriver_proxy ||= Selenium::WebDriver::Proxy.new(:http => selenium_proxy.http, :ssl => selenium_proxy.ssl)
  end

  def self.selenium_proxy
    @@selenium_proxy ||= proxy.selenium_proxy(:http, :ssl)
  end

  def self.selenium_desktop_capabilities
    @@selenium_desktop_capabilities ||= Selenium::WebDriver::Remote::Capabilities.chrome(:proxy => selenium_webdriver_proxy)
  end

  def self.selenium_mobile_capabilities
    chrome_options = {"mobileEmulation" => { "deviceName" => "Apple iPhone 5" }}
    @@selenium_mobile_capabilities ||= Selenium::WebDriver::Remote::Capabilities.chrome(:proxy => selenium_webdriver_proxy, "chromeOptions" => chrome_options)
  end

  def har
    @har ||= EdgeTest.proxy.har
  end

  def har_entries
    har.entries
  end

  def site_entry
    entries.first
  end

  def har_entries_by_page_ref
    har_entries.select{|e| e.pageref == page_ref } if page_ref
  end

  def entries
    if page_ref
      har_entries_by_page_ref
    else
      har_entries
    end
  end

  def edge_requests
    @edge_requests ||= entries.select{|e| e.request.url.include?('edge.simplereach') }
  end

  def x_requests
    @x_requests ||= edge_requests.select{|e| e.request.url.include?('/x?')}
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

  def request_parameters
    @request_parameters ||= query_string.map{|param, hash| [param["name"], param["value"]] }.to_h if query_string
  end

  def n_request_fired?
    entries.select{|e| e.request.url.include?('edge.simplereach.com/n?')}.length >= 1
  end

  def x_request_fired?
    entries.select{|e| e.request.url.include?('edge.simplereach.com/x?')}.length >= 1
  end

  def t_request_fired?
    entries.select{|e| e.request.url.include?('edge.simplereach.com/t?')}.length >= 1
  end

  def begin_test
    puts "Visiting #{url}"
    create_page_ref
    session.visit(url)
  end

  def create_page_ref
    self.class.proxy.new_page(page_ref) if page_ref
  end

  def shutdown_test
    session.driver.browser.close
  end
end
