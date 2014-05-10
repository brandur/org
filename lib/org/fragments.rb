require 'digest/md5'

module Org
  class Fragments < Sinatra::Base
    helpers Helpers::Common
    register Sinatra::Namespace

    before do
      log :access_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    configure do
      set :views, Config.root + "/views"
    end

    namespace "/fragments" do
      get do
      end

      get "/modern" do
        slim :"fragments/show", layout: !pjax?
      end
    end
  end
end
