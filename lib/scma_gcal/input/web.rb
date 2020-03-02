module SCMAGCal
  module Input
    class Web
      BASE_URL = 'https://www.rockclimbing.org'

      class EventsPage
        def remote_page(agent)
          agent.get("#{BASE_URL}/index.php/event-list/events-list")
        end

        def local_page(path)
          Nokogiri::HTML(File.open(path))
        end

        def parse(page)
          lines = extract_event_lines(page)

          lines.map do |line|
            event = parse_event(line)
            event = make_event(event)
            event
          end
        end

        # Events are listed in a <table>.
        #
        # Each event spans two rows plus a separator row between events.
        #
        # The first event row contains two columns.  The first column contains
        # a link to the event page, start date, and end date.  The second
        # column contains a link to the event page, event title, and event
        # location.
        #
        # The second event row also contains two columns.  The first column is
        # empty.  The second column contains the event activity.  The event
        # activity is normally a rephrasing of the event title so we ignore it.
        #
        # The separator row is empty with a single column that spans two columns.
        #
        # To parse this structure, we first search for all row (<tr>) tags.  Of
        # these, we then select only the row which contain two link (<a>) tags.
        # This throws out the event activity rows and the separator rows.
        #
        # Each of the remaining rows is converted into a hash that contains the
        # event text (start date, end date, subject, location) and the event
        # page URL.
        #
        # The event text contains non-breaking space and redundant whitespace
        # so we remove and collapse these respectively.
        def extract_event_lines(page)
          rows = page.search('tr')

          rows
            .select { |row| row.search('a').size == 2 }
            .map do |row|
              links = row.search('a')
              {
                text: row.text.remove_nbsp.collapse_whitespace.strip,
                url: BASE_URL + links.first['href']
              }
            end
        end

        def parse_event(event_line)
          md = event_line[:text].match(/^(?<start_date>.+?) - (?<end_date>.+?) (?<subject>.+) @( (?<location>.+))?/)
          raise "unable to parse event: '#{event_line}'" unless md
          event_hash = {'url' => event_line[:url]}.merge(md.to_hash)
          event_hash['location'] ||= ''
          event_hash
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

      class EventPage
        def remote_page(agent, url)
          agent.get(url)
        end

        def local_page(path)
          Nokogiri::HTML(File.open(path))
        end

        def parse_description(page)
          description = page.at_css('.ohanah-event-full-description')
          node_text(description).join.strip
        end

        def parse_comments(page)
          comments = page.css('.kmt-wrap')

          comments.map do |comment|
            {
              'author' => comment.at_css('.kmt-author a').text.strip,
              'text' => comment.at_css('.kmt-body').text.strip,
              'time' => comment.at_css('.kmt-time time')['datetime'],
            }
          end
        end

        def parse_attendees(page)
          attendee_spans = page.css('.who_avatars span')
          attendee_spans
            .map { |span| span.text }
            .each
            .each_slice(2)
            .map do |(attendee, data)|
              count, comment = data
                .gsub("\n", ' ')
                .gsub("\r", '')
                .remove_nbsp
                .match(/\((\d+) total\)\s*(.*)/)
                .captures
              {
                'attendee' => attendee,
                'count' => count,
                'comment' => comment,
              }
            end
        end

        def node_text(node, text = [])
          case node.name
          when 'br', 'div', 'p'
            if !text.empty?
              text << "\n"
            end
          when 'text'
            text << node.text.strip.gsub("\r", '')
          end

          node.children.each do |child|
            node_text(child, text)
          end

          text
        end
      end

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

      def read
        agent = make_agent
        login(agent, username, password)
        events_page = EventsPage.new
        $stderr.puts "Fetching events"
        html = events_page.remote_page(agent)
        events = events_page.parse(html)

        events.each do |event|
          event_page = EventPage.new
          $stderr.puts "Fetching #{event.subject} --  #{event.url}"
          html = event_page.remote_page(agent, event.url)
          event.description = event_page.parse_description(html)
          event.attendees = event_page.parse_attendees(html)
          event.comments = event_page.parse_comments(html)
        end

        events
      end
    end
  end
end
