# frozen_string_literal: true

module Infusible
  # Sanitizes and resolves dependencies for use.
  class DependencyMap
    NAME_PATTERN = /([a-z_][a-zA-Z_0-9]*)$/

    attr_reader :names

    def initialize *configuration, name_pattern: NAME_PATTERN
      @name_pattern = name_pattern
      @collection = {}

      configuration = configuration.dup
      aliases = configuration.last.is_a?(Hash) ? configuration.pop : {}

      configuration.each { |identifier| add to_name(identifier), identifier }
      aliases.each { |name, identifier| add name, identifier }

      @names = collection.keys
    end

    def to_h = collection

    private

    attr_reader :name_pattern, :collection

    def to_name identifier
      identifier.to_s[name_pattern] || fail(Errors::InvalidDependency.new(identifier:))
    end

    def add name, identifier
      name = name.to_sym

      return collection[name] = identifier unless collection.key? name

      fail Errors::DuplicateDependency.new name:, identifier:
    end
  end
end
