class Event
  attr_accessor :subject, :start_date, :end_date, :location

  def initialize(event_hash)
    event_hash.each do |k, v|
      send("#{k}=", v)
    end

    sanitize!
  end

  def sanitize!
    @subject = "SCMA: " + @subject.strip.sub(/,$/, "")
    @location.strip!

    @start_date = date_from_string(@start_date)
    @end_date = date_from_string(@end_date)

    # WORKAROUND bug(?) in Google Calendar
    # All day events spanning multiple days show as 1 day short.
    # Add one day to end date to compensate.
    if @end_date != @start_date
      @end_date += 1
    end
  end

  def to_s
      [subject, [start_date, end_date].join(" - "), location].join("\n")
  end

  def date_from_string(s)
    Date.strptime(s, "%m/%d/%y")
  end
end
