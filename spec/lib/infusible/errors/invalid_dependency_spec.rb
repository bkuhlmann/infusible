# frozen_string_literal: true

require "spec_helper"

RSpec.describe Infusible::Errors::InvalidDependency do
  subject(:error) { described_class.new identifier: "123" }

  describe "#message" do
    it "answers error message" do
      expect(error.message).to eq(%(Cannot use "123" as an identifier.))
    end
  end
end
