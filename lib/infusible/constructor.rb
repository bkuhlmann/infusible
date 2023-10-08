# frozen_string_literal: true

require "marameters"

module Infusible
  # Provides the automatic and complete resolution of all injected dependencies.
  # :reek:TooManyInstanceVariables
  class Constructor < Module
    def self.define_instance_variables target, names, keywords
      names.each do |name|
        next unless keywords.key?(name) || !target.instance_variable_defined?(:"@#{name}")

        target.instance_variable_set :"@#{name}", keywords[name]
      end
    end

    private_class_method :define_instance_variables

    def initialize container, *configuration, scope: :private
      super()

      @container = container
      @dependencies = DependencyMap.new(*configuration)
      @scope = scope
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

    attr_reader :container, :dependencies, :scope, :class_module, :instance_module

    def define klass
      define_new
      define_initialize klass
      define_readers
    end

    def define_new
      class_module.module_exec container, dependencies.to_h do |container, collection|
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

      variablizer = self.class.method :define_instance_variables

      if super_parameters.positionals? || super_parameters.only_single_splats?
        define_initialize_with_positionals super_parameters, variablizer
      else
        define_initialize_with_keywords super_parameters, variablizer
      end
    end

    def define_initialize_with_positionals super_parameters, variablizer
      instance_module.module_exec dependencies.names, variablizer do |names, definer|
        define_method :initialize do |*positionals, **keywords, &block|
          definer.call self, names, keywords

          if super_parameters.only_single_splats?
            super(*positionals, **keywords, &block)
          else
            super(*positionals, **super_parameters.keyword_slice(keywords, keys: names), &block)
          end
        end
      end
    end

    def define_initialize_with_keywords super_parameters, variablizer
      instance_module.module_exec dependencies.names, variablizer do |names, definer|
        define_method :initialize do |**keywords, &block|
          definer.call self, names, keywords
          super(**super_parameters.keyword_slice(keywords, keys: names), &block)
        end
      end
    end

    def define_readers
      methods = dependencies.names.map { |name| ":#{name}" }
      computed_scope = METHOD_SCOPES.include?(scope) ? scope : :private

      instance_module.module_eval <<-READERS, __FILE__, __LINE__ + 1
        #{computed_scope} attr_reader #{methods.join ", "}
      READERS
    end
  end
end
