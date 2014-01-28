require_relative "test_helper"

describe Org::Quotes do
  include Rack::Test::Methods

  def app
    Org::Quotes
  end

  describe "/accidental" do
    it "succeeds" do
      get "/accidental"
      assert_equal 200, last_response.status
      assert_match /hated him enormously/, last_response.body
    end
  end

  describe "/crying" do
    it "succeeds" do
      get "/crying"
      assert_equal 200, last_response.status
      assert_match /What's this on me\?/, last_response.body
    end
  end

  describe "/favors" do
    it "succeeds" do
      get "/favors"
      assert_equal 200, last_response.status
      assert_match /Get it\?/, last_response.body
    end
  end

  describe "/that-sunny-dome" do
    it "succeeds" do
      get "/that-sunny-dome"
      assert_equal 200, last_response.status
      assert_match /those caves of ice\!/, last_response.body
    end
  end

  describe "/lies" do
    it "succeeds" do
      get "/lies"
      assert_equal 200, last_response.status
      assert_match /and it was good/, last_response.body
    end
  end
end
