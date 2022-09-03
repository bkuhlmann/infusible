# frozen_string_literal: true

module Infusible
  module Errors
    # Prevents duplicate dependencies from being injected.
    class DuplicateDependency < StandardError
      def initialize name:, identifier:
        super "Remove #{identifier.inspect} since it's a duplicate of #{name.inspect}."
      end
    end
  end
end
