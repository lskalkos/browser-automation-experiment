namespace :qa do
  desc "Run Standard Implementation QA"
  task :standard, [:url, :pid] do |t, args|
    ENV["URL_UNDER_TEST"]=args[:url]
    ENV["PID_UNDER_TEST"]=args[:pid] if args[:pid]
    exec 'rspec spec/standard.rb'
  end

  desc "Run Ecommerce Implementation QA"
  task :ecomm, :url do |t, args|
    ENV["URL_UNDER_TEST"]=args[:url]
    exec 'rspec spec/ecomm.rb'
  end
end

