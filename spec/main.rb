require './edge_test'
require 'date'

describe "Standard Implementation", :type => :feature do
  url = 'http://sponsored.people.com/visitcalifornia'
  # url = 'http://www.thedrive.com/vintage/4010/the-8-most-beautiful-le-mans-cars-of-all-time'
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
      @desktop_test.session.visit(url)
      @desktop_test.session.execute_script('window.scrollTo(0,100000)')
      sleep(10)
    end

    after(:all) do
      @desktop_test.session.driver.browser.close
    end

    it 'page does not 404' do
      expect(@desktop_test.site_request.response.status).to_not eq(404)
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
      @mobile_test.session.visit(url)
      @mobile_test.session.execute_script('window.scrollTo(0,100000)')
      sleep(10)
    end

    after(:all) do
      @mobile_test.session.driver.browser.close
    end

    it 'page does not 404' do
      expect(@mobile_test.site_request.response.status).to_not eq(404)
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
      expect{ Date.parse(@mobile_test.request_parameters["date"]) }.not_to raise_error
    end
  end

  context 'adding query parameters to the url' do
    query_string = "SRQuery=true"

    context 'desktop' do
      before(:all) do
        @query_param_desktop_test = EdgeTest.new("#{url}?#{query_string}", {driver: :desktop_chrome})
        @query_param_desktop_test.session.visit("#{url}?#{query_string}")
        sleep(3)
      end

      after(:all) do
        @query_param_desktop_test.session.driver.browser.close
      end

      it 'url does not change' do
        expect(@query_param_desktop_test.request_parameters["url"]).to eq(url)
      end

      it 'page_url captures query parameters' do
        expect(@query_param_desktop_test.request_parameters["page_url"]).to match(query_string)
      end

      it 'og:url either does not exist or does not change' do
        begin
          expect(@query_param_desktop_test.session.find('meta[property="og:url"]', visible: false)["content"]).to eq(url)
        rescue Capybara::ElementNotFound
          puts "og:url not found on the page"
        end
      end
    end

    context 'mobile' do
      before(:all) do
        @query_param_mobile_test = EdgeTest.new("#{url}?#{query_string}", {driver: :mobile_chrome})
        @query_param_mobile_test.session.visit("#{url}?#{query_string}")
        sleep(3)
      end

      after(:all) do
        @query_param_mobile_test.session.driver.browser.close
      end

      it 'url does not change' do
        expect(@query_param_mobile_test.request_parameters["url"]).to eq(url)
      end

      it 'page_url captures query parameters' do
        expect(@query_param_mobile_test.request_parameters["page_url"]).to match(query_string)
      end

      it 'og:url either does not exist or does not change' do
        begin
          expect(@query_param_mobile_test.session.find('meta[property="og:url"]', visible: false)["content"]).to eq(url)
        rescue Capybara::ElementNotFound
          puts "og:url not found on the page"
        end
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
        @slash_desktop_test.session.visit(new_url)
        sleep(3)
      end

      after(:all) do
        @slash_desktop_test.session.driver.browser.close
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
        @slash_mobile_test.session.visit(new_url)
        sleep(3)
      end

      after(:all) do
        @slash_mobile_test.session.driver.browser.close
      end

      it 'url does not change' do
        expect(@slash_mobile_test.request_parameters["url"]).to eq(url)
      end
    end
  end

  context 'desktop/mobile comparison' do
    before(:all) do
      @comparison_mobile_test = EdgeTest.new(url, {driver: :mobile_chrome})
      @comparison_mobile_test.session.visit(url)
      sleep(5)

      @comparison_desktop_test = EdgeTest.new(url, {driver: :desktop_chrome})
      @comparison_desktop_test.session.visit(url)
      sleep(5)
    end

    after(:all) do
      @comparison_desktop_test.session.driver.browser.close
      @comparison_mobile_test.session.driver.browser.close
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

  context 'HTTP vs. HTTPS' do
    context 'HTTPS' do
      before(:all) do
        if url.include?('http://')
          stripped_url = url.slice(7, url.length)
          https_url = "https://#{stripped_url}"
        elsif url.include?('https://')
          https_url = url
        else
          https_url = "https://#{url}"
        end

        @https_desktop_test = EdgeTest.new(https_url, {driver: :desktop_chrome})
        puts "Visiting #{https_url}"
        @https_desktop_test.session.visit(https_url)
        sleep(5)
      end

      after(:all) do
        @https_desktop_test.session.driver.browser.close
      end

      it 'url does not change if visited with HTTPS' do
        if @https_desktop_test.site_request.response.status == 200
          expect(@https_desktop_test.request_parameters["url"]).to eq(url)
        else
          puts "HTTPS not available"
        end
      end
    end

    context 'HTTP' do
      before(:all) do
        if url.include?('http://')
          http_url = url
        elsif url.include?('https://')
          stripped_url = url.slice(8, url.length)
          http_url = "http://#{url}"
        else
          http_url = "http://#{url}"
        end

        @http_desktop_test = EdgeTest.new(http_url, {driver: :desktop_chrome})
        puts "Visiting #{http_url}"
        @http_desktop_test.session.visit(http_url)
        sleep(5)
      end

      after(:all) do
        @http_desktop_test.session.driver.browser.close
      end

      it 'url does not change if visited with HTTP' do
        expect(@http_desktop_test.request_parameters["url"]).to eq(url)
      end
    end
  end

end
