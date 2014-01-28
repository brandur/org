require_relative "test_helper"

describe Org::Photos do
  include Rack::Test::Methods

  def app
    Org::Photos
  end

  describe "/photos" do
    it "succeeds" do
      get "/photos"
      assert_equal 200, last_response.status
    end
  end

  describe "/photos/:id" do
    it "succeeds" do
      stub_photo
      get "/photos/123"
      assert_equal 200, last_response.status
    end
  end

  describe "/photos/large/:id.jpg" do
    it "succeeds" do
      stub_photo
      get "/photos/large/123.jpg"
      assert_equal 200, last_response.status
      assert_match /flickr-content/, last_response.body
      assert_equal "image/jpg", last_response.headers["Content-Type"]
    end
  end

  describe "/photos/medium/:id@2x.jpg" do
    it "succeeds" do
      stub_photo
      get "/photos/large/123@2x.jpg"
      assert_equal 200, last_response.status
      assert_match /flickr-content/, last_response.body
      assert_equal "image/jpg", last_response.headers["Content-Type"]
    end
  end

  describe "/photos/medium/:id.jpg" do
    it "succeeds" do
      stub_photo
      get "/photos/large/123.jpg"
      assert_equal 200, last_response.status
      assert_match /flickr-content/, last_response.body
      assert_equal "image/jpg", last_response.headers["Content-Type"]
    end
  end

  private

  def stub_photo
    stub(DB)[:events].stub!.first.with_any_args {
      {
        slug:     "my-photo",
        title:    "My Photo",
        metadata: {
          "large_image" => "https://flickr.com/large-image",
          "medium_image" => "https://flickr.com/medium-image",
        }
      }
    }
    stub(Excon).get.with_any_args { stub! { |r|
      r.headers { {
        "Content-Type" => "image/jpg"
      } }
      r.body { "flickr-content" }
    } }
  end
end
