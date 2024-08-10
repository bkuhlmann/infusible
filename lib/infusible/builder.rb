# frozen_string_literal: true

require "marameters"

module Infusible
  # Provides the automatic and complete resolution of all injected dependencies.
  # :reek:TooManyInstanceVariables
  class Builder < Module
    def self.define_instance_variables target, keys, keywords
      unless target.instance_variable_defined? :@infused_keys
        target.instance_variable_set :@infused_keys, keys
      end

      keys.each do |key|
        next unless keywords.key?(key) || !target.instance_variable_defined?(:"@#{key}")

        target.instance_variable_set :"@#{key}", keywords[key]
      end
    end

    private_class_method :define_instance_variables

    def initialize container, *configuration, scope: :private
      super()

      @container = container
      @dependencies = DependencyMap.new(*configuration)
      @scope = scope
      @class_module = Module.new
      @instance_module = Module.new.set_temporary_name "infusible"

      freeze
    end

    def included descendant
      unless descendant.is_a? Class
        fail TypeError,
             "Can only infuse a class, invalid object: #{descendant} (#{descendant.class})."
      end

      super
      define descendant
      descendant.extend class_module
      descendant.include instance_module
    end

    private

    attr_reader :container, :dependencies, :scope, :class_module, :instance_module

    def define descendant
      define_new
      define_initialize descendant
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

    def define_initialize descendant
      super_parameters = Marameters.of(descendant, :initialize).map do |instance|
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
      instance_module.module_exec dependencies.keys, variablizer do |keys, definer|
        define_method :initialize do |*positionals, **keywords, &block|
          definer.call self, keys, keywords

          if super_parameters.only_single_splats?
            super(*positionals, **keywords, &block)
          else
            super(*positionals, **super_parameters.keywords_for(*keys, **keywords), &block)
          end
        end
      end
    end

    def define_initialize_with_keywords super_parameters, variablizer
      instance_module.module_exec dependencies.keys, variablizer do |keys, definer|
        define_method :initialize do |**keywords, &block|
          definer.call self, keys, keywords
          super(**super_parameters.keywords_for(*keys, **keywords), &block)
        end
      end
    end

    def define_readers
      methods = dependencies.keys.map { |key| ":#{key}" }
      computed_scope = METHOD_SCOPES.include?(scope) ? scope : :private

      instance_module.module_eval <<-READERS, __FILE__, __LINE__ + 1
        attr_reader :infused_keys
        #{computed_scope} attr_reader #{methods.join ", "}
      READERS
    end
  end
end
