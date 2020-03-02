module SCMAGCal
  module Model
    class Event
      attr_accessor :subject
      attr_accessor :start_date
      attr_accessor :end_date
      attr_accessor :location
      attr_accessor :url
      attr_accessor :description
      attr_accessor :comments
      attr_accessor :attendees

      def initialize(event_hash)
        event_hash.each do |k, v|
          send("#{k}=", v)
        end
      end

      def description_string
        comments_string = comments.map do |comment|
          '* %s (%s) %s' % [
            comment['author'],
            comment['time'],
            comment['text'],
          ]
        end.join("\n")

        attendees_string = attendees.map do |attendee|
          '* %s (%s total) %s' % [
            attendee['attendee'],
            attendee['count'],
            attendee['comment'],
          ]
        end.join("\n")

        <<~EOF
          #{description}

          COMMENTS:
          #{comments_string}

          ATTENDEES:
          #{attendees_string}

          URL: #{url}
        EOF
      end
    end
  end
end
