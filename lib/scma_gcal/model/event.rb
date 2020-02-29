module SCMAGCal
  module Model
    class Event
      attr_accessor :subject, :start_date, :end_date, :location, :url

      def initialize(event_hash)
        event_hash.each do |k, v|
          send("#{k}=", v)
        end
      end
    end
  end
end
