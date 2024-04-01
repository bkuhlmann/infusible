# frozen_string_literal: true

require "infusible/actuator"
require "infusible/constructor"
require "infusible/dependency_map"
require "infusible/errors/duplicate_dependency"
require "infusible/errors/invalid_dependency"

# Main namespace.
module Infusible
  METHOD_SCOPES = %i[public protected private].freeze

  def self.[](container) = Actuator.new container

  def self.with(container) = Actuator.new container
end
