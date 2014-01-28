module Org
  class Librato
    def initialize
      @librato = Excon.new(Config.librato_url)
    end

    def get_performance_metrics
      @librato.requests([
        build_request("requests.latency.median"),
        build_request("requests.latency.perc95"),
        build_request("requests.latency.perc99"),
      ]).map { |r| MultiJson.decode(r.body)["measurements"]["unassigned"] }
    end

    private

    def build_request(metric)
      {
        expects: 200,
        method: :get,
        path: "/v1/metrics/#{metric}",
        query: {
          count: 10,
          resolution: 60,
        }
      }
    end
  end
end
