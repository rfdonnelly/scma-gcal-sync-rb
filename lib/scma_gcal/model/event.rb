module SCMAGCal
  module Model
    class Event
      attr_accessor :subject, :start_date, :end_date, :location

      def initialize(event_hash)
        event_hash.each do |k, v|
          send("#{k}=", v)
        end
      end

      def to_s
        [subject, [start_date, end_date].join(" - "), location].join("\n")
      end
    end
  end
end
