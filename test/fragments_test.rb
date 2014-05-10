require_relative "test_helper"

describe Org::Fragments do
  include Rack::Test::Methods

  def app
    Org::Fragments
  end

  describe "/fragments" do
    it "succeeds" do
      get "/fragments"
      assert_equal 200, last_response.status
      #assert_match /Lamenting the Death of the Page/, last_response.body
    end
  end

=begin
  describe "/fragments.atom" do
    it "succeeds" do
      get "/fragments.atom"
      assert_equal 200, last_response.status
      assert_match /Lamenting the Death of the Page/, last_response.body
    end
  end

  describe "/fragments/:id" do
    it "succeeds" do
      get "/fragments/modern-web-design"
      assert_equal 200, last_response.status
      assert_match /OLAP/, last_response.body
    end
  end
=end
end
