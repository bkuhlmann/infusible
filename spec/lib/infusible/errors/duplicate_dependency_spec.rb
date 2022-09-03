# frozen_string_literal: true

require "spec_helper"

RSpec.describe Infusible::Errors::DuplicateDependency do
  subject(:error) { described_class.new name: "a", identifier: :a }

  describe "#message" do
    it "answers error message" do
      expect(error.message).to eq(%(Remove :a since it's a duplicate of "a".))
    end
  end
end
