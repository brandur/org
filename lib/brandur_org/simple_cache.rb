require "thread"

module BrandurOrg
  class SimpleCache
    @@cache = {}
    @@mutex = Mutex.new

    def self.get(key, expires_at)
      @@mutex.synchronize do
        if @@cache[key] && @@cache[key][:expires_at] > Time.now
          @@cache[key][:data]
        else
          data = yield
          @@cache[key] = { data: data, expires_at: expires_at }
          data
        end
      end
    end
  end
end
