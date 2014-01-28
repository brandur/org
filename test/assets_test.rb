require_relative "test_helper"

describe Org::Assets do
  include Rack::Test::Methods

  def app
    Org::Assets
  end

  describe "/assets/:release/app.css" do
    it "succeeds" do
      get "/assets/123/app.css"
      assert_equal 200, last_response.status
    end

    it "works for any release" do
      get "/assets/456/app.css"
      assert_equal 200, last_response.status
    end
  end

  describe "/assets/:release/app.js" do
    it "succeeds" do
      get "/assets/123/app.js"
      assert_equal 200, last_response.status
    end

    it "works for any release" do
      get "/assets/456/app.js"
      assert_equal 200, last_response.status
    end
  end

  describe "/assets/*.jpg" do
    it "succeeds" do
      get "/assets/page/economist.jpg"
      assert_equal 200, last_response.status
    end
  end

  describe "/assets/*.png" do
    it "succeeds" do
      get "/assets/page/weekend.png"
      assert_equal 200, last_response.status
    end
  end
end
