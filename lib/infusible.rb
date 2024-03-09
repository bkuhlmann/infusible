# frozen_string_literal: true

# Main namespace.
module Infusible
  METHOD_SCOPES = %i[public protected private].freeze

  def self.with(container) = Actuator.new container
end
