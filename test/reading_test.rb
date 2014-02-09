require_relative "test_helper"

describe Org::Reading do
  include Rack::Test::Methods

  def app
    Org::Reading
  end

  describe "/reading" do
    it "succeeds" do
      get "/reading"
      assert_equal 200, last_response.status
      assert_match /[0-9] books/, last_response.body
    end
  end
end
