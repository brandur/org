module Org
  class Reading < Sinatra::Base
    helpers Helpers::Common
    helpers Helpers::Reading

    configure do
      set :views, Config.root + "/views"
    end

    before do
      log :access_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    get "/books" do
      redirect to("/reading")
    end

    get "/reading" do
      @books = DB[:events].reverse_order(:occurred_at).filter(type: "goodreads")

      last_modified(@books.first[:occurred_at]) if Config.production?

      @books_count = @books.count

      @books = @books.all
      @book_count_by_year, @page_count_by_year =
        count_books_and_pages_by_year(@books)
      @books = @books.group_by { |b| b[:occurred_at].year }

      @title = "Reading"
      slim :"reading/index"
    end
  end
end
