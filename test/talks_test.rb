require_relative "test_helper"

describe Org::Talks do
  include Rack::Test::Methods

  def app
    Org::Talks
  end

  describe "/talks" do
    it "succeeds" do
      get "/talks"
      assert_equal 200, last_response.status
      assert_match /Frozen Rails/, last_response.body
    end
  end
end
