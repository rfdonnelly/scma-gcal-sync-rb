module SCMAGCal
  module Input
    class Web
      attr_reader :username
      attr_reader :password

      def initialize(username, password)
        @username = username
        @password = password
      end

      def make_agent()
        agent = Mechanize.new
        agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
        agent
      end

      def login(agent, username, password)
        agent.post("https://www.rockclimbing.org/index.php/component/comprofiler/login", {
          "username" => username,
          "passwd" => password
        })

        # FIXME add check for invalid login
      end

      def get_events_page_remote(username, password)
        agent = make_agent()
        login(agent, username, password)
        agent.get("https://www.rockclimbing.org/index.php/event-list/events-list")
      end

      def get_events_page_local()
        # FIXME make a command line option
        Nokogiri::HTML(File.open("events.html"))
      end

      def extract_event_lines(page)
        page.search("tr").map { |row| row.text.remove_nbsp.collapse_whitespace.strip }
          .chunk { |line| !line.empty? || nil }
          .map { |_, event_lines| event_lines.join(" ") }
      end

      def parse_event(event_line)
        event_line.match(/^(?<start_date>.+?) - (?<end_date>.+?) (?<subject>.+) @ (?<location>.+)/).to_hash
      end

      def read
        # FIXME make commandline option to select input source
        page = get_events_page_remote(username, password)
        #page = get_events_page_local()

        extract_event_lines(page)
          .map { |line| make_event(parse_event(line)) }
      end

      def make_event(event_hash)
        event = SCMAGCal::Model::Event.new(event_hash)

        event.subject = "SCMA: " + event.subject.strip.sub(/,$/, "")
        event.location = event.location.strip
        event.start_date = date_from_s(event.start_date)
        event.end_date = date_from_s(event.end_date)

        # WORKAROUND bug(?) in Google Calendar
        # All day events spanning multiple days show as 1 day short.
        # Add one day to end date to compensate.
        if event.end_date != event.start_date
          event.end_date += 1
        end

        event
      end

      def date_from_s(s)
        Date.strptime(s, "%m/%d/%y")
      end
    end
  end
end
