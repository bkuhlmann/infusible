# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.new.then do |loader|
  loader.tag = File.basename __FILE__, ".rb"
  loader.ignore "#{__dir__}/infusible/stub"
  loader.push_dir __dir__
  loader.setup
end

# Main namespace.
module Infusible
  def self.loader(registry = Zeitwerk::Registry) = registry.loader_for __FILE__

  def self.with(container) = Actuator.new container
end
