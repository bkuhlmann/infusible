# frozen_string_literal: true

require "infusible"

module Infusible
  # Provides stubbing of the injected container when used in a test framework.
  module Stub
    refine Actuator do
      def stub_with(pairs, &)
        warn "`#{self.class}##{__method__}` is deprecated, use the Containable gem instead.",
             category: :deprecated

        return unless block_given?

        container.is_a?(Hash) ? stub_hash_with(pairs, &) : stub_container_with(pairs, &)
      end

      def stub pairs
        warn "`#{self.class}##{__method__}` is deprecated, use the Containable gem instead",
             category: :deprecated

        container.is_a?(Hash) ? stub_hash(pairs) : stub_container(pairs)
      end

      def unstub(*keys)
        warn "`#{self.class}##{__method__}` is deprecated, use the Containable gem instead",
             category: :deprecated

        container.is_a?(Hash) ? unstub_hash(*keys) : unstub_container(*keys)
      end

      private

      def stub_container_with pairs
        stub_container pairs
        yield
        unstub_container(*pairs.keys)
      end

      def stub_container pairs
        container.enable_stubs!
        pairs.each { |key, value| container.stub key, value }
      end

      def unstub_container(*keys) = keys.each { |key| container.unstub key }

      def stub_hash_with pairs
        stub_hash pairs
        yield
        unstub_hash(*pairs.keys)
      end

      def stub_hash pairs
        @backup = container.dup
        container.merge! pairs
      end

      def unstub_hash(*keys) = container.merge! @backup.slice(*keys)
    end
  end
end
