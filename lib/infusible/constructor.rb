# frozen_string_literal: true

require "marameters"

module Infusible
  # Provides the automatic and complete resolution of all injected dependencies.
  class Constructor < Module
    def initialize container, *configuration
      super()

      @container = container
      @dependencies = DependencyMap.new(*configuration)
      @class_module = Class.new(Module).new
      @instance_module = Class.new(Module).new
    end

    def included klass
      super
      define klass
      klass.extend class_module
      klass.include instance_module
    end

    private

    attr_reader :container, :dependencies, :class_module, :instance_module

    def define klass
      define_new
      define_initialize klass
      define_readers
    end

    def define_new
      class_module.class_exec container, dependencies.to_h do |container, collection|
        define_method :new do |*positionals, **keywords, &block|
          collection.each { |name, id| keywords[name] = container[id] unless keywords.key? name }
          super(*positionals, **keywords, &block)
        end
      end
    end

    def define_initialize klass
      super_parameters = Marameters.of(klass, :initialize).map do |instance|
        break instance unless instance.only_bare_splats?
      end

      if super_parameters.positionals? || super_parameters.only_single_splats?
        define_initialize_with_positionals super_parameters
      else
        define_initialize_with_keywords super_parameters
      end
    end

    def define_initialize_with_positionals super_parameters
      instance_module.class_exec dependencies.names, method(:define_variables) do |names, definer|
        define_method :initialize do |*positionals, **keywords, &block|
          definer.call self, keywords

          if super_parameters.only_single_splats?
            super(*positionals, **keywords, &block)
          else
            super(*positionals, **super_parameters.keyword_slice(keywords, keys: names), &block)
          end
        end
      end
    end

    def define_initialize_with_keywords super_parameters
      instance_module.class_exec dependencies.names, method(:define_variables) do |names, definer|
        define_method :initialize do |**keywords, &block|
          definer.call self, keywords
          super(**super_parameters.keyword_slice(keywords, keys: names), &block)
        end
      end
    end

    # :reek:FeatureEnvy
    def define_variables target, keywords
      dependencies.names.each do |name|
        next unless keywords.key?(name) || !target.instance_variable_defined?(:"@#{name}")

        target.instance_variable_set :"@#{name}", keywords[name]
      end
    end

    def define_readers
      methods = dependencies.names.map { |name| ":#{name}" }

      instance_module.class_eval <<-READERS, __FILE__, __LINE__ + 1
        private attr_reader #{methods.join ", "}
      READERS
    end
  end
end
