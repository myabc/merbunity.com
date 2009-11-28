module Merb
  module FormattingHelpers

    def formatted(str, fmt = :textile)
      RedCloth.new(str).to_html
    end
  end
end
