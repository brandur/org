module Org::Helpers
  module Runs
    def distance_by_year(runs)
      distance_by_year = {}
      runs.each do |run|
        distance_by_year[Time.parse(run[:metadata][:occurred_at_local]).year] ||= 0
        distance_by_year[Time.parse(run[:metadata][:occurred_at_local]).year] +=
          run[:metadata][:distance].to_f
      end
      distance_by_year.each do |year, distance|
        distance_by_year[year] = in_km(distance)
      end
      distance_by_year
    end

    def in_km(distance)
      distance / 1000.0
    end

    def pace(run)
      s = run[:metadata][:moving_time].to_f / in_km(run[:metadata][:distance].to_f)
      "#{(s / 60).to_i}:#{(s.to_i % 60).to_s.rjust(2, '0')}"
    end
  end
end
