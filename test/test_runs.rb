require_relative "test_helper"

describe Org::Runs do
  include Rack::Test::Methods

  def app
    Org::Runs
  end

  describe "/runs" do
    it "succeeds" do
      get "/runs"
      assert_equal 200, last_response.status
      assert_match /for a projected total of/, last_response.body
    end
  end
end
