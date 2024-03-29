module SCMAGCal
  module Output
    class GCal
      attr_reader :calendar_name
      attr_reader :dry_run

      OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
      APPLICATION_NAME = "SCMA GCal".freeze
      CREDENTIALS_PATH = "credentials.json".freeze
      # The file token.yaml stores the user's access and refresh tokens, and is
      # created automatically when the authorization flow completes for the first
      # time.
      TOKEN_PATH = "token.yml".freeze
      SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR

      # The page size can never be larger than 250 entries
      MAX_CALENDAR_LISTS = 250
      # The page size can never be larger than 2500 events.
      MAX_EVENTS = 2500

      def initialize(calendar_name, dry_run:)
        @calendar_name = calendar_name
        @dry_run = dry_run
      end

      def write(events)
        # Initialize the API
        service = Google::Apis::CalendarV3::CalendarService.new
        service.client_options.application_name = APPLICATION_NAME
        service.authorization = authorize

        calendar_id = service
          .list_calendar_lists(max_results: MAX_CALENDAR_LISTS)
          .items
          .find { |entry| entry.summary == calendar_name }
          .id

        response = service.list_events(
          calendar_id,
          max_results: MAX_EVENTS,
          single_events: true,
          order_by: "startTime",
          time_min: DateTime.now.rfc3339,
        )

        # The list_events time_min filter filters by end date.  This means
        # list_events can return events that are in-progress (started but not
        # yet ended).  While the SCMA events list page removes events when they
        # start.  If we delete all events returned by list_events, we will end
        # up deleting permanently deleting in-progress events from the
        # calendar.  To account for this, we need to further filter the events
        # returned by list_events by start date.
        to_delete = response.items.reject do |item|
          start_date = eventdatetime_to_date(item.start)
          start_date < Date.today
        end

        if !to_delete.empty?
          puts "Deleting events:"
          to_delete.each do |item|
            start_date = eventdatetime_to_date(item.start)
            end_date = eventdatetime_to_date(item.end)
            puts "- #{item.summary} (#{start_date}/#{end_date})"
            service.delete_event(calendar_id, item.id) unless dry_run
          end
        end

        puts "Inserting events:"
        events.each do |event|
          gcal_event = make_gcal_event(event)
          start_date = event.start_date
          end_date = event.end_date
          puts "- #{gcal_event.summary} (#{start_date}/#{end_date})"
          result = service.insert_event(calendar_id, gcal_event) unless dry_run
        end
      end

      # Convert a Google::Apis::CalendarV3::EventDateTime to a Date
      #
      # An EventDateTime object contains either a date (if an
      # all-day event) or a date_time (otherwise) but not both.
      def eventdatetime_to_date(edt)
        edt.date || edt.date_time.to_date
      end

      def make_gcal_event(event)
        Google::Apis::CalendarV3::Event.new(
          summary: event.subject,
          location: event.location,
          start: Google::Apis::CalendarV3::EventDateTime.new(
            date: event.start_date,
            time_zone: 'America/Los_Angeles'
          ),
          end: Google::Apis::CalendarV3::EventDateTime.new(
            date: event.end_date,
            time_zone: 'America/Los_Angeles'
          ),
          description: event.description_string,
        )
      end

      ##
      # Ensure valid credentials, either by restoring from the saved credentials
      # files or intitiating an OAuth2 authorization. If authorization is required,
      # the user's default browser will be launched to approve the request.
      #
      # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
      def authorize
        client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
        token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
        authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
        user_id = "default"
        credentials = authorizer.get_credentials user_id
        if credentials.nil?
          url = authorizer.get_authorization_url base_url: OOB_URI
          puts "Open the following URL in the browser and enter the " \
            "resulting code after authorization:\n" + url
          code = $stdin.gets
          credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id, code: code, base_url: OOB_URI
          )
        end
        credentials
      end
    end
  end
end
