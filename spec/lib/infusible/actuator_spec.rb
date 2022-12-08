# frozen_string_literal: true

require "dry/container"
require "spec_helper"

RSpec.describe Infusible::Actuator do
  describe "#[]" do
    before { stub_const "Test::Import", actuator }

    context "with container dependencies" do
      subject(:actuator) { described_class.new container }

      let :container do
        Module.new do
          extend Dry::Container::Mixin

          register(:a) { 1 }
          register(:b) { 2 }
          register(:c) { 3 }
        end
      end

      let(:child) { Class.new.include Test::Import[:a, :b, :c] }

      it "answers injected dependencies" do
        expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
      end
    end

    context "with hash dependencies" do
      subject(:actuator) { described_class.new({a: 1, b: 2, c: 3}) }

      let(:child) { Class.new.include Test::Import[:a, :b, :c] }

      it "answers injected dependencies" do
        expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
      end
    end
  end
end
