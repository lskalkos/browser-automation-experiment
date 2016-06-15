require "./edge_test"

describe "Edge Request", :type => :feature do
  before(:all) do
    url = 'http://qz.com/706493/alibabas-jack-ma-the-problem-with-counterfeits-is-theyre-better-quality-than-authentic-luxury-goods/'
    @edgetest = EdgeTest.new(url)
    @edgetest.run
    visit(url)
  end

  after(:all) do
    @edgetest.stop
  end

  it 'n call is present and fires once' do
    expect(@edgetest.n_requests.length).to eq(1)
  end

  it 'has a successful response' do
    expect(@edgetest.n_requests.first.response.status).to eq(200)
    @edgetest.stop
  end

  it 'time on site fires' do
    expect(@edgetest.t_requests.empty?).to eq(false)
    @edgetest.stop
  end
end