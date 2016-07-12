describe "Ecommerce Implementation", :type => :feature do
  url = ENV["URL_UNDER_TEST"]

  before(:all) do
    EdgeTest.run
    puts "Beginning QA for #{url}"
  end

  after(:all) do
    EdgeTest.stop
    puts "Finished QA for #{url}"
  end

  context 'pixels' do
    before(:all) do
      @pixel_test = EdgeTest.new(url)
      @pixel_test.session.visit(url)
      wait.until{ @pixel_test.x_request_fired? }
    end

    after(:all) do
      @pixel_test.session.driver.browser.close
    end

    it 'x call is present and fires once' do
      expect(@pixel_test.x_requests.length).to eq(1)
    end

    it 'TTD Universal pixel present' do
      expect(@pixel_test.x_requests.first.response.content.text).to include("TTDUniversalPixelApi")
    end

    it 'Facebook pixel present' do
      expect(@pixel_test.x_requests.first.response.content.text).to include("Facebook Pixel")
    end
  end
end
