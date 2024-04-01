# frozen_string_literal: true

require "spec_helper"

RSpec.describe Infusible do
  subject(:infusible) { described_class }

  describe ".[]" do
    it "answers injected dependencies" do
      stub_const "Test::Container", {a: 1, b: 2, c: 3}
      stub_const "Test::Import", infusible[Test::Container]
      child = Class.new.include Test::Import[:a, :b, :c]

      expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
    end
  end

  describe ".with" do
    before { stub_const "Test::Container", {a: 1, b: 2, c: 3} }

    it "answers injected dependencies" do
      stub_const "Test::Import", infusible.with(Test::Container)
      child = Class.new.include Test::Import[:a, :b, :c]

      expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
    end

    it "answers deprecation warning" do
      expectation = proc { stub_const "Test::Import", infusible.with(Test::Container) }
      output = "`Infusible.with` is deprecated, use `.[]` instead.\n"

      expect(&expectation).to output(output).to_stderr
    end
  end
end
