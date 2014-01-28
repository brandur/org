require_relative "test_helper"

describe Org::Articles do
  include Rack::Test::Methods

  def app
    Org::Articles
  end

  describe "/articles" do
    it "succeeds" do
      get "/articles"
      assert_equal 200, last_response.status
      assert_match /Lamenting the Death of the Page/, last_response.body
    end
  end

  describe "/articles.atom" do
    it "succeeds" do
      get "/articles.atom"
      assert_equal 200, last_response.status
      assert_match /Lamenting the Death of the Page/, last_response.body
    end
  end

  # sample signature article
  describe "/page" do
    it "succeeds" do
      get "/page"
      assert_equal 200, last_response.status
      assert_match /convenient points of reference/, last_response.body
    end
  end
end
