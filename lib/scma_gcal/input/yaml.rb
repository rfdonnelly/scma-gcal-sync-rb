module SCMAGCal
  module Input
    class YAML
      attr_reader :file

      def initialize(file)
        @file = file
      end

      def read
        ::YAML
          .load_file(file)
          .map { |entry| SCMAGCal::Model::Event.new(entry) }
      end
    end
  end
end
