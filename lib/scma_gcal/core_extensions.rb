module CoreExtensions
  module String
    module RemoveNBSP
      def remove_nbsp
        gsub("\u00A0", ' ')
      end
    end

    module CollapseWhitespace
      def collapse_whitespace
        gsub(/\s+/, ' ')
      end
    end
  end

  module MatchData
    module ToHash
      def to_hash
        Hash[names.zip(captures)]
      end
    end
  end
end
