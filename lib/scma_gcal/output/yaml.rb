module SCMAGCal
  module Output
    class YAML
      def write(events)
        puts events
          .map { |event| event_to_hash(event) }
          .to_yaml
      end

      def event_to_hash(event)
        {
          'subject' => event.subject,
          'start_date' => event.start_date,
          'end_date' => event.end_date,
          'location' => event.location,
          'url' => event.url,
        }
      end
    end
  end
end
