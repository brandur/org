require "securerandom"

module Org
  class Instruments
    def initialize(app, options={})
      @app = app
    end

    def call(env)
      return @app.call(env) \
        if IGNORE_EXTENSIONS.any? { |ext|
          env["REQUEST_PATH"] =~ /\.#{ext}$/
        }

      request_ids = [SecureRandom.uuid]
      status, headers, response = nil, nil, nil

      # make ID of the request accessible to consumers down the stack
      env["REQUEST_ID"] = request_ids[0]

      # Extract request IDs from incoming headers as well. Can be used for
      # identifying a request across a number of components in SOA.
      if @header_request_ids
        request_ids += extract_request_ids(env)
        env["REQUEST_IDS"] = request_ids.join(",")
      end

      data = {
        app:        "brandur-org",
        method:     env["REQUEST_METHOD"],
        path:       env["REQUEST_PATH"],
        ip:         env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"],
        request_id: request_ids.join(","),
        at:         "start",
      }
      log(:instrumentation, data)

      start = Time.now
      status, headers, response = @app.call(env)
      elapsed = (Time.now - start).to_f

      data.merge!({
        at:      "finish",
        elapsed: format("%.3f", elapsed),
        status:  status,
      })
      log(:instrumentation, data)
      puts("count#requests=1")
      puts("measure#requests.latency=#{elapsed}s")

      headers["Request-Id"] = request_ids[0]

      [status, headers, response]
    end

    private

    IGNORE_EXTENSIONS = %w{css gif ico jpg js jpeg pdf png}.freeze
    UUID_PATTERN =
      /\A([a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}|[a-f0-9]{32})\Z/

    def extract_request_ids(env)
      request_ids = []
      if env["HTTP_REQUEST_ID"]
        request_ids = env["HTTP_REQUEST_ID"].split(",")
        request_ids.map! { |id| id.strip }
        request_ids.select! { |id| id =~ @request_id_pattern }
      end
      request_ids
    end

    def log(action, data)
      unparsed = data.map { |k, v| "#{k}=#{v}" }.join(" ")
      puts "#{action} #{unparsed}"
    end
  end
end
