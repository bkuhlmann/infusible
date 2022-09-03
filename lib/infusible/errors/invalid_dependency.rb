# frozen_string_literal: true

module Infusible
  module Errors
    # Prevents improperly named dependencies from being injected.
    class InvalidDependency < StandardError
      def initialize identifier:
        super "Cannot use #{identifier.inspect} as an identifier."
      end
    end
  end
end
