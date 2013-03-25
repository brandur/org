module BrandurOrg
  module Config
    extend self

    def force_ssl?
      @force_ssl ||= %w{1 true yes}.include?(env("FORCE_SSL"))
    end

    def production?
      @production ||= env("RACK_ENV") == "production"
    end

    def release
      @release ||= env("RELEASE") || "1"
    end

    def root
      @root ||= File.expand_path("../../../", __FILE__)
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
