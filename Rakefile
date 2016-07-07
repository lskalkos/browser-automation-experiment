namespace :qa do
  desc "Run Standard Implementation QA"
  task :standard, :url do |t, args|
    ENV["URL_UNDER_TEST"]=args[:url]
    exec 'rspec spec/standard.rb'
  end

  desc "Run Ecommerce Implementation QA"
  task :ecomm, :url do |t, args|
    ENV["URL_UNDER_TEST"]=args[:url]
    exec 'rspec spec/ecomm.rb'
  end
end
