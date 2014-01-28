module Org
  class Twitter < Sinatra::Base
    helpers Helpers::Common
    helpers Helpers::Twitter

    configure do
      set :views, Config.root + "/views"
    end

    before do
      log :access_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    get "/twitter" do
      @tweets = DB[:events].reverse_order(:occurred_at).filter(type: "twitter").
        filter("metadata -> 'reply' = 'false'")
      last_modified(@tweets[0][:occurred_at]) if Config.production?
      @tweets = @tweets.all
      @tweets = group_by_month_and_year(@tweets)
      @title = "Twitter"
      slim :"twitter/index"
    end
  end
end
