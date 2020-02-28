module SCMAGCal
  module Output
    class GCal
      OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
      APPLICATION_NAME = "Google Calendar API Ruby Quickstart".freeze
      CREDENTIALS_PATH = "credentials.json".freeze
      # The file token.yaml stores the user's access and refresh tokens, and is
      # created automatically when the authorization flow completes for the first
      # time.
      TOKEN_PATH = "token.yaml".freeze
      SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR

      # The page size can never be larger than 250 entries
      MAX_CALENDAR_LISTS = 250
      # The page size can never be larger than 2500 events.
      MAX_EVENTS = 2500
      CALENDAR_NAME = "SCMA"

      def write(events)
        # Initialize the API
        service = Google::Apis::CalendarV3::CalendarService.new
        service.client_options.application_name = APPLICATION_NAME
        service.authorization = authorize

        calendar_id = service
          .list_calendar_lists(max_results: MAX_CALENDAR_LISTS)
          .items
          .find { |entry| entry.summary == CALENDAR_NAME }
          .id

        response = service.list_events(
          calendar_id,
          max_results: MAX_EVENTS,
          single_events: true,
          order_by: "startTime",
          time_min: DateTime.now.rfc3339,
        )
        if !response.items.empty?
          puts "Deleting events:"
          response.items.each do |event|
            start = event.start.date || event.start.date_time
            puts "- #{event.summary} (#{start})"
            service.delete_event(calendar_id, event.id)
          end
        end

        puts "Inserting events:"
        events.each do |event|
          gcal_event = make_gcal_event(event)
          start = gcal_event.start.date
          puts "- #{gcal_event.summary} (#{start})"
          result = service.insert_event(calendar_id, gcal_event)
        end
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
