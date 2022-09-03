# frozen_string_literal: true

module Infusible
  # Associates the container with the constructor for actualization.
  class Actuator
    def initialize container, constructor: Infusible::Constructor
      @container = container
      @constructor = constructor
    end

    def [](*configuration) = constructor.new container, *configuration

    private

    attr_reader :container, :constructor
  end
end
