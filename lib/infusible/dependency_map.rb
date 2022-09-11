# frozen_string_literal: true

module Infusible
  # Sanitizes and resolves dependencies for use.
  class DependencyMap
    PATTERNS = {name: /([a-z_][a-zA-Z_0-9]*)$/, valid: /^[\w.]+$/}.freeze

    attr_reader :names

    def initialize *configuration, patterns: PATTERNS
      @patterns = patterns
      @collection = {}

      configuration = configuration.dup
      aliases = configuration.last.is_a?(Hash) ? configuration.pop : {}

      configuration.each { |identifier| add to_name(identifier), identifier }
      aliases.each { |name, identifier| add name, identifier }

      @names = collection.keys
    end

    def to_h = collection

    private

    attr_reader :patterns, :collection

    def to_name identifier
      name = identifier[patterns.fetch(:name)]

      return name if name && name.match?(patterns.fetch(:valid))

      fail(Errors::InvalidDependency.new(identifier:))
    end

    def add name, identifier
      name = name.to_sym

      return collection[name] = identifier unless collection.key? name

      fail Errors::DuplicateDependency.new name:, identifier:
    end
  end
end
