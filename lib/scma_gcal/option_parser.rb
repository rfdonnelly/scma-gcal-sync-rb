module SCMAGCal
  Options = Struct.new(
    :username,
    :password,
    :output,
  )

  class OptionParser
    def defaults
      options = Options.new
      options.output = CSV.new
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

        op.on('-oOUTPUT', '--output=OUTPUT', 'Output format.  One of: csv or yaml.  Default: csv') do |arg|
          case arg
          when 'csv'
            options.output = CSV.new
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
      raise 'missing --username option' if options.username.nil?
      raise 'missing --password option' if options.password.nil?
    end
  end
end
