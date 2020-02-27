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
        case options.input
        when :web
          SCMAGCal::Input::Web.new(options.username, options.password)
        when :yaml
          SCMAGCal::Input::YAML.new(options.file)
        end

      events = input.read

      options.output.write(events)
    end

    def error(message)
      $stderr.puts message
        .split("\n")
        .map { |line| "error: #{line}" }
        .join("\n")
    end
  end
end
