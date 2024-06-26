# frozen_string_literal: true

require "spec_helper"

RSpec.describe Infusible::DependencyMap do
  subject(:dependency_map) { described_class.new(*configuration) }

  describe "#keys" do
    context "with keys, namespaces, and aliases" do
      let(:configuration) { [:a, "n.b", {demo: "test"}] }

      it "answers keys as symbols" do
        expect(dependency_map.keys).to eq(%i[a b demo])
      end

      it "is frozen" do
        expect(dependency_map.keys.frozen?).to be(true)
      end
    end
  end

  describe "#to_h" do
    context "with keys (symbols, strings, and underscores)" do
      let(:configuration) { [:a, "b", :c_test] }

      it "answers symbolized keys with original values" do
        expect(dependency_map.to_h).to eq(a: :a, b: "b", c_test: :c_test)
      end
    end

    context "with keys (numbers)" do
      let(:configuration) { %w[1a b2 0c3] }

      it "answers symbolized keys, stripped of leading numbers, with original values" do
        expect(dependency_map.to_h).to eq(a: "1a", b2: "b2", c3: "0c3")
      end
    end

    context "with namespaces" do
      let(:configuration) { %w[n.a n.b n.m.c] }

      it "answers symbolized keys, stripped of namespace, with original values" do
        expect(dependency_map.to_h).to eq(a: "n.a", b: "n.b", c: "n.m.c")
      end
    end

    context "with aliases" do
      let(:configuration) { [a: "space.sun", b: "space.moon"] }

      it "answers aliased keys with original values" do
        expect(dependency_map.to_h).to eq(a: "space.sun", b: "space.moon")
      end
    end

    context "with keys, namespaces, and aliases" do
      let(:configuration) { [:a, "n.b", {demo: "test"}] }

      it "answers sanitized and symbolized keys with original values" do
        expect(dependency_map.to_h).to eq(a: :a, b: "n.b", demo: "test")
      end
    end

    context "with duplicate key" do
      let(:configuration) { [:a, "a"] }

      it "fails with duplicate key" do
        expectation = proc { dependency_map.to_h }
        expect(&expectation).to raise_error(Infusible::Errors::DuplicateDependency, /"a"/)
      end
    end

    context "with duplicate keys and namespaces" do
      let(:configuration) { ["one.a", "one.a"] }

      it "fails with duplicate key" do
        expectation = proc { dependency_map.to_h }
        expect(&expectation).to raise_error(Infusible::Errors::DuplicateDependency, /"one\.a"/)
      end
    end

    context "with duplicate key but different namespaces" do
      let(:configuration) { ["one.a", "two.a"] }

      it "fails with duplicate key" do
        expectation = proc { dependency_map.to_h }
        expect(&expectation).to raise_error(Infusible::Errors::DuplicateDependency, /"two\.a"/)
      end
    end

    context "with duplicate key and alias" do
      let(:configuration) { [:a, {a: "test"}] }

      it "fails with duplicate key" do
        expectation = proc { dependency_map.to_h }
        expect(&expectation).to raise_error(Infusible::Errors::DuplicateDependency, /"test"/)
      end
    end

    context "with duplicate namespace and alias" do
      let(:configuration) { ["test.a", {a: "test"}] }

      it "fails with duplicate key" do
        expectation = proc { dependency_map.to_h }
        expect(&expectation).to raise_error(Infusible::Errors::DuplicateDependency, /"test"/)
      end
    end

    context "with key of numbers only" do
      let(:configuration) { ["123"] }

      it "fails with duplicate key" do
        expectation = proc { dependency_map.to_h }
        expect(&expectation).to raise_error(Infusible::Errors::InvalidDependency, /"123"/)
      end
    end

    context "with key of special characters only" do
      let(:configuration) { ["/@!$%\\"] }

      it "fails with duplicate key" do
        expectation = proc { dependency_map.to_h }
        expect(&expectation).to raise_error(Infusible::Errors::InvalidDependency, %r("/@!\$%\\\\"))
      end
    end
  end
end
