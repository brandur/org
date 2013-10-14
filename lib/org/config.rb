require "cgi"

module Org
  module Config
    extend self

    def black_swan_database_url
      url = env!("BLACK_SWAN_DATABASE_URL")
      if RUBY_PLATFORM == 'java'
        url = URI.parse(url)
        params = {}
        params["user"] = url.user if url.user
        params["password"] = url.password if url.password
        "jdbc:postgresql://#{url.host}:#{url.port || 5432}#{url.path}?" +
          params.map { |k, v| "#{k}=#{v}" }.join("&")
      else
        url
      end
    end

    def force_ssl?
      %w{1 true yes}.include?(env("FORCE_SSL"))
    end

    def google_analytics_id
      env("GOOGLE_ANALYTICS_ID")
    end

    def librato_url
      user = CGI.escape(env!("LIBRATO_USER"))
      token = CGI.escape(env!("LIBRATO_TOKEN"))
      "https://#{user}:#{token}@metrics-api.librato.com"
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
