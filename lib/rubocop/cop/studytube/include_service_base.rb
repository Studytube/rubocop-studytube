# frozen_string_literal: true

module RuboCop
  module Cop
    module Studytube
      # please include ServiceBase into a service class
      #
      # @example
      #   # bad
      #   class AnyService
      #     def self.call
      #     end
      #   end
      #
      #   # good
      #   class AnyService
      #     include ServiceBase
      #
      #     def call
      #     end
      #   end
      class IncludeServiceBase < Base
        extend AutoCorrector

        MSG = 'please include ServiceBase into a service class'

        def_node_search :include_declarations, '(send nil? :include (:const ... $_) ...)'
        def_node_matcher :super_class_declarations, '(class (const nil? _) (const ...) ...)'
        def_node_matcher :instance_call_declarations, '(def :call (args) ...)'
        def_node_matcher :class_call_declarations, '(defs (self) :call (args) ...)'

        def on_defs(node)
          class_node = class_node(node)

          return unless class_node
          return if super_class_declarations(class_node) # skip if class has parent declaration

          # `include ServiceBase` + `def self.call`
          if include_service_base?(class_node) && class_call_declarations(node)
            add_offense(node, message: 'You have to use `def call`')
          end

          # no `include ServiceBase` + `self.call`
          return unless !include_service_base?(class_node) && class_call_declarations(node)

          add_offense(class_node) do |corrector|
            add_servicebase(corrector, class_node)
            corrector.replace(node.child_nodes.first, '') # removes `self`
            corrector.replace(node.loc.operator, '') # removes `.`
          end
        end

        def on_def(node)
          class_node = class_node(node)

          return unless class_node
          return if super_class_declarations(class_node) # skip if class has parent declaration

          # no `def call`
          return unless instance_call_declarations(node)

          # no `include ServiceBase`
          return if include_service_base?(class_node)

          add_offense(class_node) do |corrector|
            corrector.insert_after(class_node.child_nodes.first,
                                   "\n#{' ' * node.source_range.column}include ServiceBase")
          end
        end

        def include_service_base?(node)
          include_declarations(node).any? do |current|
            current.to_s.eql?('ServiceBase')
          end
        end

        def class_node(node)
          node.each_ancestor(:class).first
        end

        def add_servicebase(corrector, node)
          target_node = first_include_node(node)

          if target_node
            indent = ' ' * target_node.source_range.column
            corrector.insert_before(target_node, "include ServiceBase\n#{indent}")
            return
          end

          target_node = node.child_nodes.first
          indent = ' ' * node.each_descendant(:def, :defs).first.source_range.column
          corrector.insert_after(target_node, "\n#{indent}include ServiceBase\n")
        end

        def first_include_node(node)
          node.each_descendant(:send) do |child_node|
            return child_node if child_node.children[1] == :include
          end

          nil
        end
      end
    end
  end
end
