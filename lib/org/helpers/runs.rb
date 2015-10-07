module Org::Helpers
  module Runs
    # Filters the set of runs so as to only show those from the current year.
    def current_year(runs)
      runs.
        where("extract(year from (metadata -> 'occurred_at_local')::timestamp) = ?",
          Time.now.year)
    end

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

    # Sums the distance of the given set of runs (note that the result is in
    # meters).
    def distance_sum(runs)
      runs.inject(0.0) { |sum, run| sum + run[:metadata][:distance].to_f }
    end

    # Estimates what the annual distance total will be given all the runs in
    # the current year.
    def estimate(runs)
      distance = distance_sum(current_year(runs))
      in_km(distance / Time.now.yday.to_f * 365).round(1)
    end

    # Estimates what the annual distance total will be given all the runs in
    # the current year but extrapolating using only the activity of the last 30
    # days.
    def estimate_last_30_days(runs)
      last_month = Time.now - 30 * 24 * 3600
      last_30, other = current_year(runs).
        partition { |run|
          Time.parse(run[:metadata][:occurred_at_local]) >= last_month
        }
      distance_last_30 = distance_sum(last_30)
      distance_other = distance_sum(other)

      remaining_days = 365.0 - Time.now.yday.to_f
      distance_estimate = distance_last_30 / 30.0 * remaining_days

      distance = distance_other + distance_last_30 + distance_estimate
      in_km(distance).round(1)
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
