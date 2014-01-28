require_relative "test_helper"

describe Org::Tenets do
  include Rack::Test::Methods

  def app
    Org::Tenets
  end

  describe "/tenets" do
    it "succeeds" do
      get "/tenets"
      assert_equal 200, last_response.status
      assert_match /not happiness/, last_response.body
    end
  end
end
