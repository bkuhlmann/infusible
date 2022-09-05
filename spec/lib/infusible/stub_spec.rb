# frozen_string_literal: true

require "spec_helper"
require "dry/container"
require "dry/container/stub"
require "infusible/stub"

RSpec.describe Infusible::Stub do
  using described_class

  subject(:infusible) { Infusible.with Test::Container }

  let(:child) { Class.new.include Test::Import[:a, :b, :c] }

  let :container do
    Module.new do
      extend Dry::Container::Mixin

      register :a, 1
      register :b, 2
      register :c, 3
    end
  end

  describe "#stub_with" do
    context "with primitive hash" do
      before do
        stub_const "Test::Container", {a: 1, b: 2, c: 3}
        stub_const "Test::Import", infusible
      end

      it "answers stubbed dependencies with block" do
        Test::Import.stub_with a: 100, b: 200, c: 300 do
          expect(child.new.inspect).to include("@a=100, @b=200, @c=300")
        end
      end

      it "answers original dependencies without block" do
        Test::Import.stub_with a: 100, b: 200, c: 300
        expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
      end
    end

    context "with Dry Container" do
      before do
        stub_const "Test::Container", container
        stub_const "Test::Import", infusible
      end

      it "answers stubbed dependencies with block" do
        Test::Import.stub_with a: 100, b: 200, c: 300 do
          expect(child.new.inspect).to include("@a=100, @b=200, @c=300")
        end
      end

      it "answers original dependencies without block" do
        Test::Import.stub_with a: 100, b: 200, c: 300
        expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
      end
    end
  end

  describe "#stub" do
    context "with primitive hash" do
      before do
        stub_const "Test::Container", {a: 1, b: 2, c: 3}
        stub_const "Test::Import", infusible
      end

      it "answers stubbed dependencies" do
        Test::Import.stub a: 100, b: 200, c: 300
        expect(child.new.inspect).to include("@a=100, @b=200, @c=300")
      end
    end

    context "with Dry Container" do
      before do
        stub_const "Test::Container", container
        stub_const "Test::Import", infusible
      end

      it "answers stubbed dependencies" do
        Test::Import.stub a: 100, b: 200, c: 300
        expect(child.new.inspect).to include("@a=100, @b=200, @c=300")
      end
    end
  end

  describe "#unstub" do
    context "with primitive hash" do
      before do
        stub_const "Test::Container", {a: 1, b: 2, c: 3}
        stub_const "Test::Import", infusible

        Test::Import.stub a: 100, b: 200, c: 300
      end

      it "answers original dependencies" do
        Test::Import.unstub :a, :b, :c
        expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
      end
    end

    context "with Dry Container" do
      before do
        stub_const "Test::Container", container
        stub_const "Test::Import", infusible

        Test::Import.stub a: 100, b: 200, c: 300
      end

      it "answers original dependencies" do
        Test::Import.unstub :a, :b, :c
        expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
      end
    end
  end
end
