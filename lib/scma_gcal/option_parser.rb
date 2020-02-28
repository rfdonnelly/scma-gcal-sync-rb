module SCMAGCal
  Options = Struct.new(
    :username,
    :password,
    :file,
    :input,
    :output,
  )

  class OptionParser
    def defaults
      options = Options.new
      options.username = ENV['SCMA_USERNAME']
      options.password = ENV['SCMA_PASSWORD']
      options.input = SCMAGCal::Input::Web
      options.output = SCMAGCal::Output::CSV
      options
    end

    def parse(argv)
      options = defaults

      op = ::OptionParser.new do |op|
        op.banner = "Usage: scma-gcal [options]"

        op.on('-uUSERNNAME', '--username=USERNAME', 'Username for rockclimbing.org') do |arg|
          options.username = arg
        end
        op.on('-pPASSWORD', '--password=PASSWORD', 'Password for rockclimbing.org') do |arg|
          options.password = arg
        end

        op.on('-fFILE', '--file=FILE', 'Input file.') do |arg|
          options.file = arg
        end

        op.on('-iINPUT', '--input=INPUT', 'Input type: yaml, web. Default: web') do |arg|
          case arg
          when 'web'
            options.input = SCMAGCal::Input::Web
          when 'yaml'
            options.input = SCMAGCal::Input::YAML
          else
            raise SCMAGCal::Error, 'unrecognized input type for the --input option'
          end
        end

        op.on('-oOUTPUT', '--output=OUTPUT', 'Output format.  One of: csv, gcal, yaml.  Default: csv') do |arg|
          case arg
          when 'csv'
            options.output = SCMAGCal::Output::CSV
          when 'yaml'
            options.output = SCMAGCal::Output::YAML
          when 'gcal'
            options.output = SCMAGCal::Output::GCal
          else
            raise SCMAGCal::Error, 'unrecognized output format for the --output option'
          end
        end

        op.on('-h', '--help', 'Print this help') do
          puts op
          exit
        end
      end

      op.parse!(argv)

      validate(options)

      options
    end

    def validate(options)
      if options.input == SCMAGCal::Input::Web
        raise SCMAGCal::Error, 'the web input requires the --username option' if options.username.nil?
        raise SCMAGCal::Error, 'the web input requires the --password option' if options.password.nil?
      elsif options.input == SCMAGCal::Input::YAML
        raise SCMAGCal::Error, 'the yaml input requires the --file option' if options.file.nil?
      end
    end
  end
end
