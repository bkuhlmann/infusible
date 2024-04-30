# frozen_string_literal: true

require "spec_helper"

RSpec.describe Infusible::Builder do
  before { stub_const "Test::Builder", described_class.new({eins: 1, zwei: 2}, :eins, :zwei) }

  describe ".ancestors" do
    it "answers ancestors" do
      implementation = Class.new.include(Test::Builder).set_temporary_name "test"

      expect(implementation.ancestors.map(&:inspect)).to eq(
        [
          "test",
          "infusible-parent",
          "Test::Builder",
          "Object",
          "PP::ObjectMixin",
          "JSON::Ext::Generator::GeneratorMethods::Object",
          "DEBUGGER__::TrapInterceptor",
          "Kernel",
          "BasicObject"
        ]
      )
    end
  end

  describe "#initialize" do
    it "is frozen" do
      builder = described_class.new({eins: 1})
      expect(builder.frozen?).to be(true)
    end
  end

  describe "#included" do
    it "fails with type error when infusing a module" do
      expectation = proc { Module.new { include Test::Builder } }

      expect(&expectation).to raise_error(
        TypeError,
        /Can only infuse a class, invalid object:.+<Module.+> \(Module\)./
      )
    end

    context "with names only" do
      let :child do
        Class.new do
          include Test::Builder

          def frozen_infused_keys? = infused_keys.frozen?

          def frozen_infused_names? = infused_names.frozen?

          def to_a = infused_names.map { |key| __send__ key }
        end
      end

      it "has frozen infused names only" do
        expect(child.new.frozen_infused_names?).to be(true)
      end

      it "answers dependencies based on infused names" do
        expect(child.new.to_a).to eq([1, 2])
      end

      it "shows deprecation warning for infused names" do
        expectation = proc { child.new.frozen_infused_names? }
        warning = "`Inusible#infused_names` is deprecated, use `#infused_keys` instead.\n"

        expect(&expectation).to output(warning).to_stderr
      end

      it "has frozen infused keys only" do
        expect(child.new.frozen_infused_keys?).to be(true)
      end
    end

    context "with names, namespaces, and aliases" do
      let :child do
        Class.new.include described_class.new(
          {eins: 1, "primary.zwei" => 2, "primary.three" => 3},
          :eins,
          "primary.zwei",
          {drei: "primary.three"}
        )
      end

      it "includes infused keys" do
        expect(child.new.inspect).to include("@infused_keys=[:eins, :zwei, :drei]")
      end

      it "includes injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2, @drei=3")
      end
    end

    context "with private scope" do
      let :child do
        Class.new.include described_class.new({eins: 1, zwei: 2}, :eins, scope: :private)
      end

      it "includes infused keys" do
        expect(child.new.inspect).to include("@infused_keys=[:eins]")
      end

      it "fails when attempting to access private dependency" do
        expectation = proc { child.new.eins }
        expect(&expectation).to raise_error(NameError, /private method/)
      end
    end

    context "with protected scope" do
      let :child do
        Class.new.include described_class.new({eins: 1, zwei: 2}, :eins, scope: :protected)
      end

      it "includes infused keys" do
        expect(child.new.inspect).to include("@infused_keys=[:eins]")
      end

      it "fails when attempting to access protected dependency" do
        expectation = proc { child.new.eins }
        expect(&expectation).to raise_error(NameError, /protected method/)
      end
    end

    context "with public scope" do
      let :child do
        Class.new.include described_class.new({eins: 1, zwei: 2}, :eins, scope: :public)
      end

      it "includes infused keys" do
        expect(child.new.inspect).to include("@infused_keys=[:eins]")
      end

      it "answers dependency" do
        expect(child.new.eins).to eq(1)
      end
    end

    context "with invalid scope" do
      let :child do
        Class.new.include described_class.new({eins: 1, zwei: 2}, :eins, scope: :bogus)
      end

      it "fails when attempting to access private dependency" do
        expectation = proc { child.new.eins }
        expect(&expectation).to raise_error(NameError, /private method/)
      end
    end

    context "with partially injected dependencies" do
      let(:child) { Class.new.include described_class.new({eins: 1, zwei: 2}, :eins) }

      it "includes infused keys" do
        expect(child.new.inspect).to include("@infused_keys=[:eins]")
      end

      it "includes specific injected dependencies" do
        expect(child.new.inspect).to include("@eins=1")
      end

      it "fails when accessing privately injected dependencies" do
        expectation = proc { child.new.eins }
        expect(&expectation).to raise_error(NoMethodError, /private method.+a.+/)
      end
    end

    context "with all possible parameters" do
      let :child do
        Class.new do
          include Test::Builder

          def initialize one, two = "two", *three, four:, five: 5, **, &six
            super(**)
            @one = one
            @two = two
            @three = three
            @four = four
            @five = five
            @six = six
          end

          private

          attr_reader :one, :two, :three, :four, :five, :six
        end
      end

      it "includes injected dependencies" do
        function = proc { "test" }
        instance = child.new(:one, :c, :d, four: 4, &function)

        expect(instance.inspect).to include(
          "@eins=1, @zwei=2, @one=:one, @two=:c, @three=[:d], @four=4, @five=5, @six=#<Proc"
        )
      end
    end

    context "with all possible inherited parameters" do
      let :parent do
        Class.new do
          def initialize one, two = "two", *three, four:, five: 5, **six, &seven
            @one = one
            @two = two
            @three = three
            @four = four
            @five = five
            @six = six
            @seven = seven
          end

          def to_a = [one, two, three, four, five, six, seven]

          private

          attr_reader :one, :two, :three, :four, :five, :six, :seven
        end
      end

      let :child do
        Class.new parent do
          include Test::Builder

          def initialize one, two = "two", *three, four:, five: 5, **, &seven
            super
          end

          def to_a = [eins, zwei, *super]
        end
      end

      it "answers injected dependencies" do
        function = proc { "test" }
        instance = child.new(:one, :two, :three, four: 4, six: 6, &function)

        expect(instance.to_a).to eq([1, 2, :one, :two, [:three], 4, 5, {six: 6}, function])
      end
    end

    context "with parent and no parameters" do
      let :parent do
        Class.new do
          def initialize
            @obscured = :obscured
          end

          protected

          attr_reader :obscured
        end
      end

      let(:child) { Class.new(parent).include Test::Builder }

      it "includes injected dependencies plus parent instance variable" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2, @obscured=:obscured")
      end
    end

    context "with parent and different arguments" do
      let :parent do
        Class.new do
          def initialize other
            @other = other
          end

          protected

          attr_reader :other
        end
      end

      let(:child) { Class.new(parent).include Test::Builder }

      it "includes injected dependencies plus child to parent dependency" do
        expect(child.new(:other).inspect).to include("@eins=1, @zwei=2, @other=:other")
      end
    end

    context "with parent and named single splat" do
      let :parent do
        Class.new do
          def initialize *any
            @any = any
          end

          protected

          attr_reader :any
        end
      end

      let(:child) { Class.new(parent).include Test::Builder }

      it "includes injected dependencies plus splatted dependencies from child" do
        instance = child.new :one, :two

        expect(instance.inspect).to include(
          "@eins=1, @zwei=2, @any=[:one, :two, {:eins=>1, :zwei=>2}]"
        )
      end
    end

    context "with parent and keyword arguments (optional and splat)" do
      let :parent do
        Class.new do
          def initialize eins: :unknown, **rest
            @first = eins
            @rest = rest
          end

          private

          attr_reader :first, :rest
        end
      end

      let(:child) { Class.new(parent).include Test::Builder }

      it "includes matched overridden dependency and keyword splat" do
        instance = child.new eins: :one, zwei: 2, c: 3
        expect(instance.inspect).to include("@eins=:one, @zwei=2, @first=:one, @rest={:c=>3}")
      end
    end

    context "with multiple inheritance using unnamed single splat" do
      let :child do
        mod = Module.new { def initialize(*) = super() }

        Class.new do
          include mod
          include Test::Builder
        end
      end

      it "includes injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2")
      end
    end

    context "with multiple inheritance using unnamed double splat" do
      let :child do
        mod = Module.new { def initialize(**) = super }

        Class.new do
          include mod
          include Test::Builder
        end
      end

      it "includes injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2")
      end
    end

    context "with multiple inheritance using unnamed single and double splats" do
      let :child do
        mod = Module.new { def initialize(*, **) = super }

        Class.new do
          include mod
          include Test::Builder
        end
      end

      it "includes injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2")
      end
    end

    context "with inheritance and parent injections only" do
      let(:parent) { Class.new.include described_class.new({a: 1, b: 2}, :a, :b) }
      let(:child) { Class.new(parent).include Test::Builder }

      it "includes parent infused keys only" do
        expect(parent.new.inspect).to include("@infused_keys=[:a, :b]")
      end

      it "includes child, not parent, infused keys" do
        expect(child.new.inspect).to include("@infused_keys=[:eins, :zwei]")
      end

      it "includes child preferred injected dependencies" do
        expect(child.new.inspect).to include("@eins=1, @zwei=2")
      end
    end

    context "with inheritance and mixed injections" do
      let(:parent) { Class.new.include described_class.new({a: 1, b: 2}, :a, :b) }
      let(:child) { Class.new(parent).include described_class.new({a: 3, b: 4}, :b) }

      it "includes parent infused keys only" do
        expect(parent.new.inspect).to include("@infused_keys=[:a, :b]")
      end

      it "includes child, not parent, infused keys" do
        expect(child.new.inspect).to include("@infused_keys=[:b]")
      end

      it "includes child preferred injected dependencies" do
        expect(child.new.inspect).to include("@b=4, @a=1")
      end
    end
  end
end
