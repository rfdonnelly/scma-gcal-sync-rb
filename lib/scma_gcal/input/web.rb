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

  def events
    # FIXME make commandline option to select input source
    page = get_events_page_remote(username, password)
    #page = get_events_page_local()
    
    extract_event_lines(page)
      .map { |line| Event.new(parse_event(line)) }
  end
end
