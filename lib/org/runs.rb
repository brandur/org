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
      @runs = @runs.limit(10).all
      @title = "Runs"
      slim :"runs/index"
    end
  end
end
