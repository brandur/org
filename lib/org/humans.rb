module Org
  class Humans < Sinatra::Base
    before do
      cache_control :public, :must_revalidate, max_age: 3600
    end

    get "/humans.txt" do
      content_type(:text)
      <<-eos
Brandur Leach (@brandur)
      eos
    end
  end
end
