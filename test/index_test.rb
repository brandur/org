require_relative "test_helper"

describe Org::Index do
  include Rack::Test::Methods

  def app
    Org::Index
  end

  describe "/" do
    it "succeeds" do
      get "/"
      assert_equal 200, last_response.status
    end
  end
end
