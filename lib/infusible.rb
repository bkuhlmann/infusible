# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.then do |loader|
  loader.ignore "#{__dir__}/infusible/stub"
  loader.setup
end

# Main namespace.
module Infusible
  def self.with(container) = Actuator.new container
end
