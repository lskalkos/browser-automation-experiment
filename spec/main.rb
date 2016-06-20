require './edge_test'
require 'date'

describe "Edge Request", :type => :feature do
  url = 'http://time.com/partner/medc/detroit-art-of-the-comeback'
  before(:all) do
    EdgeTest.run
    puts "Beginning QA for #{url}"
  end

  after(:all) do
    EdgeTest.stop
    puts "Finished QA for #{url}"
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

    it 'date is valid' do
      expect{ Date.parse(@desktop_test.request_parameters["date"]) }.not_to raise_error
    end
  end

  context 'mobile' do
    before(:all) do
      @mobile_test = EdgeTest.new(url, {driver: :mobile_chrome})
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

    it 'date is valid' do
      expect{ Date.parse(@desktop_test.request_parameters["date"]) }.not_to raise_error
    end
  end

  context 'adding query parameters to the url' do
    query_string = "SRQuery=true"

    context 'desktop' do
      before(:all) do
        @query_param_desktop_test = EdgeTest.new("#{url}?#{query_string}", {driver: :desktop_chrome})
        visit("#{url}?#{query_string}")
        sleep(3)
      end

      it 'url does not change' do
        expect(@query_param_desktop_test.request_parameters["url"]).to eq(url)
      end

      it 'page_url captures query parameters' do
        expect(@query_param_desktop_test.request_parameters["page_url"]).to match(query_string)
      end
    end

    context 'mobile' do
      before(:all) do
        @query_param_mobile_test = EdgeTest.new("#{url}?#{query_string}", {driver: :mobile_chrome})
        visit("#{url}?#{query_string}")
        sleep(3)
      end

      it 'url does not change' do
        expect(@query_param_mobile_test.request_parameters["url"]).to eq(url)
      end

      it 'page_url captures query parameters' do
        expect(@query_param_mobile_test.request_parameters["page_url"]).to match(query_string)
      end
    end
  end

  context 'adding or removing / from the url' do
    context 'desktop' do
      before(:all) do
        if url[-1] === '/'
          new_url = url.chomp('/')
        else
          new_url = "#{url}/"
        end

        @slash_desktop_test = EdgeTest.new(new_url, {driver: :desktop_chrome})
        puts "Visiting #{new_url}"
        visit(new_url)
        sleep(3)
      end

      it 'url does not change' do
        expect(@slash_desktop_test.request_parameters["url"]).to eq(url)
      end
    end

    context 'mobile' do
      before(:all) do
        if url[-1] === '/'
          new_url = url.chomp('/')
        else
          new_url = "#{url}/"
        end

        @slash_mobile_test = EdgeTest.new(new_url, {driver: :mobile_chrome})
        puts "Visiting #{new_url}"
        visit(new_url)
        sleep(3)
      end

      it 'url does not change' do
        expect(@slash_mobile_test.request_parameters["url"]).to eq(url)
      end
    end
  end

  context 'desktop/mobile comparison' do
    before(:all) do
      @comparison_mobile_test = EdgeTest.new(url, {driver: :mobile_chrome})
      visit(url)
      sleep(5)

      @comparison_desktop_test = EdgeTest.new(url, {driver: :desktop_chrome})
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
