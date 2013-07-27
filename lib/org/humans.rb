module Org
  class Humans < Sinatra::Base
    get "/humans.txt" do
      content_type(:text)
      <<-eos
Brandur Leach (@brandur)
      eos
    end
  end
end
