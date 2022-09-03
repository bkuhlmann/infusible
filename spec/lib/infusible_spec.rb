# frozen_string_literal: true

require "spec_helper"

RSpec.describe Infusible do
  subject(:infusible) { described_class.with Test::Container }

  before do
    stub_const "Test::Container", {a: 1, b: 2, c: 3}
    stub_const "Test::Import", infusible
  end

  describe ".with" do
    let(:child) { Class.new.include Test::Import[:a, :b, :c] }

    it "answers injected dependencies" do
      expect(child.new.inspect).to include("@a=1, @b=2, @c=3")
    end
  end
end
