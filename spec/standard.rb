describe "Standard Implementation", :type => :feature do
  url = ENV["URL_UNDER_TEST"]
  pid = ENV["PID_UNDER_TEST"]

  before(:all) do
    EdgeTest.run(url)
  end

  after(:all) do
    EdgeTest.stop(url)
  end

  describe 'standard tests' do
    before(:all) do
      @desktop_test = EdgeTest.new(url, {page_ref: "desktop"})
      @mobile_test = EdgeTest.new(url, {driver: :mobile_chrome, page_ref: "mobile"})
    end
    context 'desktop' do
      before(:all) do
        @desktop_test.begin_test
        @desktop_test.session.execute_script('window.scrollTo(0,100000)')
        sleep(10)
      end

      after(:all) do
        @desktop_test.shutdown_test
      end

      it 'n call is present and fires once' do
        expect(@desktop_test.n_requests.length).to eq(1)
      end

      it 'has a successful response' do
        expect(@desktop_test.n_response.status).to eq(200)
      end

      it 'time on site fires' do
        expect(@desktop_test.t_requests.empty?).to eq(false)
      end

      it 'date is valid' do
        expect{ Date.parse(@desktop_test.request_date) }.not_to raise_error
      end

      it 'n response does not error' do
        if (@desktop_test.n_response.content.text.include?("error"))
          puts "Error response: #{@desktop_test.n_response.content.text}"
        end
        expect(@desktop_test.n_response.content.text).to_not match("error")
      end
    end

    context 'mobile' do
      before(:all) do
        @mobile_test.begin_test
        @mobile_test.session.execute_script('window.scrollTo(0,100000)')
        sleep(10)
      end

      after(:all) do
        @mobile_test.shutdown_test
      end

      it 'n call is present and fires once' do
        expect(@mobile_test.n_requests.length).to eq(1)
      end

      it 'has a successful response' do
        expect(@mobile_test.n_response.status).to eq(200)
      end

      it 'time on site fires' do
        expect(@mobile_test.t_requests.empty?).to eq(false)
      end

      it 'date is valid' do
        expect{ Date.parse(@mobile_test.request_date) }.not_to raise_error
      end

      it 'n response does not error' do
        if (@mobile_test.n_response.content.text.include?("error"))
          puts "Error response: #{@mobile_test.n_response.content.text}"
        end
        expect(@mobile_test.n_response.content.text).to_not match("error")
      end

      describe 'mobile/desktop comparison' do
        if pid
          it 'pid matches supplied pid' do
            expect(@desktop_test.request_pid).to eq(pid)
            expect(@mobile_test.request_pid).to eq(pid)
          end
        end
        it 'mobile and desktop parameters are the same' do
          EdgeTest::COMPARISON_PARAMS.each do |p|
            if @mobile_test.request_parameters[p] == @desktop_test.request_parameters[p]
              puts "#{p} same on desktop and mobile: #{@mobile_test.request_parameters[p]}".colorize(:light_blue)
            else
              puts puts "#{p} mismatch detected:"
              puts "mobile: #{@mobile_test.request_parameters[p]}"
              puts "desktop: #{@desktop_test.request_parameters[p]}"
            end

            expect(@mobile_test.request_parameters[p]).to eq(@desktop_test.request_parameters[p])
          end
        end
      end
    end
  end

  describe 'adding query parameters to the url' do
    query_string = "SRQuery=true"

    context 'desktop' do
      before(:all) do
        @query_param_desktop_test = EdgeTest.new("#{url}?#{query_string}", {driver: :desktop_chrome})
        @query_param_desktop_test.begin_test
        wait.until{ @query_param_desktop_test.n_request_fired? }
      end

      after(:all) do
        @query_param_desktop_test.shutdown_test
      end

      it 'url does not change' do
        expect(@query_param_desktop_test.request_url).to eq(url)
      end

      it 'page_url captures query parameters' do
        expect(@query_param_desktop_test.request_page_url).to match(query_string)
      end

      it 'og:url either does not exist or does not change' do
        begin
          expect(@query_param_desktop_test.og_url).to eq(url)
        rescue Capybara::ElementNotFound
          puts "og:url not found on the page"
        end
      end
    end

    context 'mobile' do
      before(:all) do
        @query_param_mobile_test = EdgeTest.new("#{url}?#{query_string}", {driver: :mobile_chrome})
        @query_param_mobile_test.begin_test
        wait.until{ @query_param_mobile_test.n_request_fired? }
      end

      after(:all) do
        @query_param_mobile_test.shutdown_test
      end

      it 'url does not change' do
        expect(@query_param_mobile_test.request_url).to eq(url)
      end

      it 'page_url captures query parameters' do
        expect(@query_param_mobile_test.request_page_url).to match(query_string)
      end

      it 'og:url either does not exist or does not change' do
        begin
          expect(@query_param_mobile_test.og_url).to eq(url)
        rescue Capybara::ElementNotFound
          puts "og:url not found on the page"
        end
      end

    end
  end

  describe 'adding or removing / from the url' do
    context 'desktop' do
      before(:all) do
        if url[-1] === '/'
          puts "Adding /"
          new_url = url.chomp('/')
        else
          puts "Removing /"
          new_url = "#{url}/"
        end

        @slash_desktop_test = EdgeTest.new(new_url, {driver: :desktop_chrome})
        @slash_desktop_test.begin_test
        @continue_slash_desktop_test = true
        begin
          wait.until{ @slash_desktop_test.n_request_fired? }
        rescue Selenium::WebDriver::Error::TimeOutError
          @continue_slash_desktop_test = false
        end
      end

      after(:all) do
        @slash_desktop_test.shutdown_test
      end

      it 'url does not change' do
        if @slash_desktop_test.site_entry.response.status == 200
          expect(@slash_desktop_test.request_url).to eq(url)
        else
          puts "page did not return 200"
        end
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
        @slash_mobile_test.begin_test
        @continue_slash_mobile_test = true
        begin
          wait.until{ @slash_mobile_test.n_request_fired? }
        rescue Selenium::WebDriver::Error::TimeOutError
          @continue_slash_mobile_test = false
        end
      end

      after(:all) do
        @slash_mobile_test.shutdown_test
      end

      it 'url does not change' do
        if @slash_mobile_test.site_entry.response.status == 200
          expect(@slash_mobile_test.request_url).to eq(url)
        else
          puts "page did not return 200"
        end
      end
    end
  end

  describe 'HTTP vs. HTTPS' do
    context 'HTTPS', unless: EdgeTest.url_https?(url) do
      before(:all) do
        @continue_https_test = true
        if url.include?('http://')
          stripped_url = url.slice(7, url.length)
          https_url = "https://#{stripped_url}"
        else
          https_url = "https://#{url}"
        end

        @https_desktop_test = EdgeTest.new(https_url, {driver: :desktop_chrome})
        begin
          @https_desktop_test.begin_test
        rescue Net::ReadTimeout
          @continue_https_test = false
        end
      end

      after(:all) do
        @https_desktop_test.shutdown_test
      end

      it 'url does not change if visited with HTTPS' do
        if @https_desktop_test.site_entry.response.status == 200
          wait.until{ @https_desktop_test.n_request_fired? }
          expect(@https_desktop_test.request_url).to eq(url)
        else
          puts "HTTPS not available"
        end
      end
    end

    context 'HTTP', unless: EdgeTest.url_http?(url) do
      before(:all) do
        if url.include?('https://')
          stripped_url = url.slice(8, url.length)
          http_url = "http://#{stripped_url}"
        else
          http_url = "http://#{url}"
        end

        @http_desktop_test = EdgeTest.new(http_url, {driver: :desktop_chrome})
        @http_desktop_test.begin_test
        wait.until{ @http_desktop_test.n_request_fired? }
      end

      after(:all) do
        @http_desktop_test.shutdown_test
      end

      it 'url does not change if visited with HTTP' do
        expect(@http_desktop_test.request_url).to eq(url)
      end
    end
  end

end
