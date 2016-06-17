require "./edge_test"

def desktop_check

end

describe "Edge Request", :type => :feature do
  url = 'http://qz.com/706493/alibabas-jack-ma-the-problem-with-counterfeits-is-theyre-better-quality-than-authentic-luxury-goods/'
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
      Capybara.current_driver = :iphone
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
end
