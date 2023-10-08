# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Import" do
  before do
    stub_const "Test::Container", {one: 1, two: 2, three: 3}
    stub_const "Test::Import", Infusible.with(Test::Container)
  end

  it "answers public message" do
    child = Class.new.include Test::Import.public(:one)
    expect(child.new.one).to eq(1)
  end

  it "fails to respond to protected message" do
    child = Class.new.include Test::Import.protected(:one)
    expectation = proc { child.new.one }

    expect(&expectation).to raise_error(NameError, /protected method.+one/)
  end

  it "fails to respond to private message" do
    child = Class.new.include Test::Import[:one]
    expectation = proc { child.new.one }

    expect(&expectation).to raise_error(NameError, /private method.+one/)
  end
end
