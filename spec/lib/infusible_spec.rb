# frozen_string_literal: true

require "spec_helper"

RSpec.describe Infusible do
  subject(:infusible) { described_class }

  describe ".loader" do
    it "eager loads" do
      expectation = proc { described_class.loader.eager_load force: true }
      expect(&expectation).not_to raise_error
    end

    it "answers unique tag" do
      expect(described_class.loader.tag).to eq("infusible")
    end
  end

  describe ".with" do
    before do
      stub_const "Test::Container", {a: 1, b: 2, c: 3}
      stub_const "Test::Import", infusible.with(Test::Container)
    end

    it "answers injected dependencies" do
      child = Class.new.include Test::Import[:a, :b, :c]
      expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
    end
  end
end
