require_relative "test_helper"

describe Org::Twitter do
  include Rack::Test::Methods

  def app
    Org::Twitter
  end

  describe "/twitter" do
    it "succeeds" do
      get "/twitter"
      assert_equal 200, last_response.status
      assert_match /[0-9] tweets/, last_response.body
    end

    it "takes a with_replies parameter" do
      get "/twitter?with_replies=true"
      assert_equal 200, last_response.status
      assert_match /[0-9] tweets/, last_response.body
    end
  end
end
