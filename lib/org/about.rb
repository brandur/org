require "time"

module Org
  class About < Sinatra::Base
    helpers Helpers::Common

    configure do
      set :views, Config.root + "/views"
    end

    before do
      log :access_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    get "/about" do
      @title = "About"
      slim :about, layout: !pjax?
    end

    get "/data/performance-metrics" do
      responses = Librato.new.get_performance_metrics
      # We want to do as few API calls as possible so allow rack-cache to
      # take care of caching these results for us. The chart's resolution
      # is 60s, so we only need to freshen the data at that rate.
      cache_control :public, :must_revalidate, max_age: 60
      content_type :json

      MultiJson.encode({
        axis: responses[0].map { |i|
          Time.at(i["measure_time"]).strftime("%H:%M")
        },
        data: {
          p50: responses[0].map { |i| i["value"] },
          p95: responses[1].map { |i| i["value"] },
          p99: responses[2].map { |i| i["value"] },
        }
      })
    end
  end
end
