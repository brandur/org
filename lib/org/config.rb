module Org
  module Config
    extend self

    def events_url
      env!("EVENTS_URL")
    end

    def force_ssl?
      %w{1 true yes}.include?(env("FORCE_SSL"))
    end

    def google_analytics_id
      env("GOOGLE_ANALYTICS_ID")
    end

    def production?
      env("RACK_ENV") == "production"
    end

    def release
      env("RELEASE") || "1"
    end

    def root
      File.expand_path("../../../", __FILE__)
    end

    private

    def env(k)
      ENV[k] if ENV[k] != ""
    end

    def env!(k)
      env(k) || raise("missing_environment=#{k}")
    end
  end
end
