# frozen_string_literal: true

module Infusible
  # Sanitizes and resolves dependencies for use.
  class DependencyMap
    PATTERNS = {key: /([a-z_][a-zA-Z_0-9]*)$/, valid: /^[\w.]+$/}.freeze

    attr_reader :keys

    def initialize *configuration, patterns: PATTERNS
      @patterns = patterns
      @collection = {}

      aliases = configuration.last.is_a?(Hash) ? configuration.pop : {}

      configuration.each { |identifier| add to_key(identifier), identifier }
      aliases.each { |key, identifier| add key, identifier }

      @keys = collection.keys.freeze
    end

    def to_h = collection

    private

    attr_reader :patterns, :collection

    def to_key identifier
      key = identifier[patterns.fetch(:key)]

      return key if key && key.match?(patterns.fetch(:valid))

      fail Errors::InvalidDependency.new(identifier:)
    end

    def add key, identifier
      key = key.to_sym

      return collection[key] = identifier unless collection.key? key

      fail Errors::DuplicateDependency.new(key:, identifier:)
    end
  end
end
