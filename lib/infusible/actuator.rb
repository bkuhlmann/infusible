# frozen_string_literal: true

module Infusible
  # Associates the container with the builder for actualization.
  class Actuator
    def initialize container, builder: Infusible::Builder
      @container = container
      @builder = builder
    end

    def [](*configuration) = builder.new container, *configuration

    def public(*configuration) = builder.new container, *configuration, scope: __method__

    def protected(*configuration) = builder.new container, *configuration, scope: __method__

    private

    attr_reader :container, :builder
  end
end
