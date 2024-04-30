# frozen_string_literal: true

module Infusible
  # Associates the container with the constructor for actualization.
  class Actuator
    def initialize container, constructor: Infusible::Builder
      @container = container
      @constructor = constructor
    end

    def [](*configuration) = constructor.new container, *configuration

    def public(*configuration) = constructor.new container, *configuration, scope: __method__

    def protected(*configuration) = constructor.new container, *configuration, scope: __method__

    private

    attr_reader :container, :constructor
  end
end
