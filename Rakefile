require 'colorize'

namespace :qa do
  desc "Run Standard Implementation QA"
  task :standard do |t, args|
    unless ENV["URL_UNDER_TEST"]
      puts "You must specify the URL_UNDER_TEST".red.on_blue
      return
    end
    exec 'rspec spec/standard.rb'
  end

  desc "Run Ecommerce Implementation QA"
  task :ecomm do |t, args|
    exec 'rspec spec/ecomm.rb'
  end
end

