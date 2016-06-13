require 'selenium-webdriver'
require 'byebug'
gem 'selenium-client'
require 'selenium-client'
require 'browsermob-proxy'

server = BrowserMob::Proxy::Server.new("/Users/liaskalkos/Desktop/SimpleReach/experiment/browsermob-proxy-2.1.1/bin/browsermob-proxy", log: true) #=> #<BrowserMob::Proxy::Server:0x000001022c6ea8 ...>
byebug
server.start

proxy=server.create_proxy
profile = Selenium::WebDriver::Chrome::Profile.new
profile.proxy = proxy.selenium_proxy

# Specify the driver path
chromedriver_path = "/Users/liaskalkos/Desktop/SimpleReach/experiment/chromedriver"
Selenium::WebDriver::Chrome.driver_path = chromedriver_path
driver = Selenium::WebDriver.for :chrome, :profile => profile
proxy.new_har("google")
driver.get('http://www.google.com')

byebug

har = proxy.har


