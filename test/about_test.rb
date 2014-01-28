require_relative "test_helper"

describe Org::About do
  include Rack::Test::Methods

  def app
    Org::About
  end

  describe "/about" do
    it "succeeds" do
      get "/about"
      assert_equal 200, last_response.status
    end
  end

  describe "/data/performance-metrics" do
    it "succeeds" do
      any_instance_of(Org::Librato) { |l|
        stub(l).get_performance_metrics {
          [
            # median
            [ { "measure_time" => Time.now.to_i, "value" => 0.1 } ],
            # perc95
            [ { "measure_time" => Time.now.to_i, "value" => 0.1 } ],
            # perc99
            [ { "measure_time" => Time.now.to_i, "value" => 0.1 } ],
          ]
        }
      }
      get "/data/performance-metrics"
      assert_equal 200, last_response.status
    end
  end
end
