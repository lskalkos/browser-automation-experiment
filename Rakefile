task :test, :url do |t, args|
  ENV["URL_UNDER_TEST"]=args[:url]
  exec 'rspec spec/main.rb'
end
