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
      options.output = SCMAGCal::Output::CSV.new
      options.input = :web
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
            options.input = :web
          when 'yaml'
            options.input = :yaml
          else
            raise 'unrecognized input type for the --input option'
          end
        end

        op.on('-oOUTPUT', '--output=OUTPUT', 'Output format.  One of: csv or yaml.  Default: csv') do |arg|
          case arg
          when 'csv'
            options.output = SCMAGCal::Output::CSV.new
          when 'yaml'
            options.output = SCMAGCal::Output::YAML.new
          else
            raise 'unrecognized output format for the --output option'
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
      case options.input
      when :web
        raise 'missing --username option' if options.username.nil?
        raise 'missing --password option' if options.password.nil?
      when :yaml
        raise 'missing --file option' if options.file.nil?
      end
    end
  end
end
