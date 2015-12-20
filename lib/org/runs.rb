module Org
  class Runs < Sinatra::Base
    helpers Helpers::Common
    helpers Helpers::Runs

    configure do
      set :views, Config.root + "/views"
    end

    before do
      log :access_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    get "/runs" do
      @runs = DB[:events].reverse_order(:occurred_at).filter(type: "strava").
        filter("metadata -> 'type' = 'Run'")
      if Config.production? && run = @runs.first
        last_modified(run[:occurred_at])
      end
      @distance_by_year = distance_by_year(@runs)
      @distance_last_year = distance_last_year(@runs)
      @tally = (@distance_by_year[Time.now.year] || 0.0).round(1)
      @estimate = estimate(@runs)
      @estimate_last_30_days = estimate_last_30_days(@runs)
      @runs = @runs.limit(30).all.
        group_by { |r| Time.parse(r[:metadata][:occurred_at_local]).month }
      @title = "Runs"
      slim :"runs/index"
    end
  end
end
