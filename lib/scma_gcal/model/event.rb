module SCMAGCal
  module Model
    class Event
      attr_accessor :subject
      attr_accessor :start_date
      attr_accessor :end_date
      attr_accessor :location
      attr_accessor :url
      attr_accessor :description

      def initialize(event_hash)
        event_hash.each do |k, v|
          send("#{k}=", v)
        end
      end
    end
  end
end
