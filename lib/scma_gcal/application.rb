module SCMAGCal
  class Application
    def run(argv)
      begin
        run_with_exceptions(argv)
      rescue SCMAGCal::Error => e
        error(e.message)
        exit 1
      rescue ::OptionParser::ParseError => e
        error(e.message)
        exit 1
      end
    end

    def run_with_exceptions(argv)
      options = SCMAGCal::OptionParser.new.parse(argv.clone)

      input =
        if options.input == SCMAGCal::Input::Web
          SCMAGCal::Input::Web.new(options.username, options.password)
        elsif options.input == SCMAGCal::Input::YAML
          SCMAGCal::Input::YAML.new(options.file)
        end

      output =
        if options.output == SCMAGCal::Output::CSV
          SCMAGCal::Output::CSV.new
        elsif options.output == SCMAGCal::Output::YAML
          SCMAGCal::Output::YAML.new
        elsif options.output == SCMAGCal::Output::GCal
          SCMAGCal::Output::GCal.new
        end

      events = input.read

      output.write(events)
    end

    def error(message)
      $stderr.puts message
        .split("\n")
        .map { |line| "error: #{line}" }
        .join("\n")
    end
  end
end
