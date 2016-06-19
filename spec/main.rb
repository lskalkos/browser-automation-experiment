require "./edge_test"

describe "Edge Request", :type => :feature do
  url = 'http://time.com/partner/medc/detroit-art-of-the-comeback'
  before(:all) do
    EdgeTest.run
  end

  after(:all) do
    EdgeTest.stop
  end

  context 'desktop' do
    before(:all) do
      @desktop_test = EdgeTest.new(url)
      visit(url)
      page.execute_script('window.scrollTo(0,100000)')
      sleep(10)
    end
    it 'n call is present and fires once' do
      expect(@desktop_test.n_requests.length).to eq(1)
    end

    it 'has a successful response' do
      expect(@desktop_test.n_requests.first.response.status).to eq(200)
    end

    it 'time on site fires' do
      expect(@desktop_test.t_requests.empty?).to eq(false)
    end
  end

  context 'mobile' do
    before(:all) do
      Capybara.default_driver = :mobile_chrome
      @mobile_test = EdgeTest.new(url)
      visit(url)
      page.execute_script('window.scrollTo(0,100000)')
      sleep(10)
    end
    it 'n call is present and fires once' do
      expect(@mobile_test.n_requests.length).to eq(1)
    end

    it 'has a successful response' do
      expect(@mobile_test.n_requests.first.response.status).to eq(200)
    end

    it 'time on site fires' do
      expect(@mobile_test.t_requests.empty?).to eq(false)
    end
  end

  context 'adding query parameters to the url' do
    context 'desktop' do
      before(:all) do
        Capybara.default_driver = :desktop_chrome
        query_string = "SRQuery=true"
        @query_param_desktop_test = EdgeTest.new("#{url}?#{query_string}")
        visit(url)
        sleep(3)
      end

      it 'url does not change' do
        expect(@query_param_desktop_test.request_parameters["url"]).to eq(url)
      end
    end

    context 'mobile' do
      before(:all) do
        Capybara.default_driver = :mobile_chrome
        query_string = "SRQuery=true"
        @query_param_mobile_test = EdgeTest.new("#{url}?#{query_string}")
        visit(url)
        sleep(3)
      end

      it 'url does not change' do
        expect(@query_param_mobile_test.request_parameters["url"]).to eq(url)
      end
    end
  end

  context 'desktop/mobile comparison' do
    before(:all) do
      Capybara.default_driver = :mobile_chrome
      @comparison_mobile_test = EdgeTest.new(url)
      visit(url)
      sleep(5)

      Capybara.default_driver = :desktop_chrome
      @comparison_desktop_test = EdgeTest.new(url)
      visit(url)
      sleep(5)
    end

    it 'mobile and desktop parameters are the same' do
      EdgeTest::COMPARISON_PARAMS.each do |p|
        if @comparison_mobile_test.request_parameters[p] == @comparison_desktop_test.request_parameters[p]
          puts "#{p} same on desktop and mobile: #{@comparison_mobile_test.request_parameters[p]}"
        else
          puts puts "#{p} mismatch detected:"
          puts "mobile: #{@comparison_mobile_test.request_parameters[p]}"
          puts "desktop: #{@comparison_desktop_test.request_parameters[p]}"
        end

        expect(@comparison_mobile_test.request_parameters[p]).to eq(@comparison_desktop_test.request_parameters[p])
      end
    end
  end
end
