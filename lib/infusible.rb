# frozen_string_literal: true

require "infusible/actuator"
require "infusible/builder"
require "infusible/dependency_map"
require "infusible/errors/duplicate_dependency"
require "infusible/errors/invalid_dependency"

# Main namespace.
module Infusible
  METHOD_SCOPES = %i[public protected private].freeze

  def self.[](container) = Actuator.new container

  def self.with container
    warn "`Infusible.#{__method__}` is deprecated, use `.[]` instead.", category: :deprecated
    Actuator.new container
  end
end
