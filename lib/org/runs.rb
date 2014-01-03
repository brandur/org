module Org
  class Runs < Sinatra::Base
    helpers Helpers::Common

    configure do
      set :views, Config.root + "/views"
    end

    get "/runs" do
      @runs = DB[:events].reverse_order(:occurred_at).filter(type: "strava").
        filter("metadata -> 'type' = 'Run'")
      last_modified(@runs.first[:occurred_at]) if Config.production?
      @distance_by_year = distance_by_year(@runs)
      @runs = @runs.limit(10).all
      @title = "Runs"
      slim :"runs/index"
    end

    private

    def distance_by_year(runs)
      distance_by_year = {}
      runs.each do |run|
        distance_by_year[run[:occurred_at].year] ||= 0
        distance_by_year[run[:occurred_at].year] +=
          run[:metadata][:distance].to_f
      end
      distance_by_year.each do |year, distance|
        distance_by_year[year] = in_km(distance)
      end
      distance_by_year
    end

    def in_km(distance)
      distance / 1000.0
    end

    def pace(run)
      s = run[:metadata][:moving_time].to_f / in_km(run[:metadata][:distance].to_f)
      "#{(s / 60).to_i}:#{(s.to_i % 60).to_s.rjust(2, '0')}"
    end
  end
end
