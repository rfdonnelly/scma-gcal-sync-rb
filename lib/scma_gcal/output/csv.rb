module SCMAGCal
  module Output
    class CSV
      def header
        "Subject, Start Date, End Date, All Day Event, Location, Description"
      end

      def write(events)
        puts header
        events.each { |event| puts entry(event) }
      end

      def entry(entry)
        '"%s", %s, %s, True, "%s", "%s"' % [
          entry.subject,
          csv_date(entry.start_date),
          csv_date(entry.end_date),
          entry.location,
          entry.description_string,
        ]
      end

      def csv_date(date)
        date.strftime("%m/%d/%Y")
      end
    end
  end
end
