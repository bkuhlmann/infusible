# frozen_string_literal: true

require "dry/container"
require "spec_helper"

RSpec.describe Infusible::Actuator do
  before { stub_const "Test::Import", actuator }

  describe "#[]" do
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

      it "includes injected dependencies" do
        expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
      end
    end

    context "with hash dependencies" do
      subject(:actuator) { described_class.new({a: 1, b: 2, c: 3}) }

      let(:child) { Class.new.include Test::Import[:a, :b, :c] }

      it "includes injected dependencies" do
        expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
      end
    end
  end

  describe "#public" do
    subject(:actuator) { described_class.new container }

    let :container do
      Module.new do
        extend Dry::Container::Mixin

        register(:a) { 1 }
        register(:b) { 2 }
        register(:c) { 3 }
      end
    end

    it "answers injected dependencies" do
      child = Class.new.include Test::Import.public(:a, :b, :c)
      expect(child.new).to have_attributes(a: 1, b: 2, c: 3)
    end
  end

  describe "#protected" do
    subject(:actuator) { described_class.new container }

    let :container do
      Module.new do
        extend Dry::Container::Mixin

        register(:a) { 1 }
        register(:b) { 2 }
        register(:c) { 3 }
      end
    end

    it "fails when accessing a protected method" do
      child = Class.new.include Test::Import.protected(:a)
      expectation = proc { child.new.a }

      expect(&expectation).to raise_error(NameError, /protected method/)
    end
  end
end
