require_relative "test_helper"

describe Org::Humans do
  include Rack::Test::Methods

  def app
    Org::Humans
  end

  describe "/humans.txt" do
    it "succeeds" do
      get "/humans.txt"
      assert_equal 200, last_response.status
      assert_match /Brandur/, last_response.body
    end
  end
end
