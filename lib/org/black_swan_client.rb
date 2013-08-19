module Org
  class BlackSwanClient
    def initialize
      @client = Excon.new(
        "#{Config.events_url}",
        headers: { "Accept" => "application/json" }
      )
    end

    def get_events(type, options={})
      res = @client.get(
        path:    "/events",
        expects: 200,
        query:   {
          limit: options[:limit] || 10,
          type:  type,
          order: options[:order] || "desc",
        }
      )
      MultiJson.decode(res.body)
    end
  end
end
