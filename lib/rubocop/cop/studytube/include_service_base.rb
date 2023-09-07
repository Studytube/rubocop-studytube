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
        def_node_search :instance_call_declarations, '(def :call (args) ...)'
        def_node_search :self_call_with_arg_declaration, '(defs self :call (args _ ...) ...)'
        def_node_search :self_call_declarations, '(defs self :call (args) ...)'
        def_node_search :self_call_with_nested_constructors_with_arg,
                        '(defs self :call (args) (send (send nil? :new _ ...) :call))'
        def_node_search :self_call_with_nested_constructors, '(defs self :call (args) (send (send nil? :new) :call))'
        def_node_search :include_service_base, '(send nil? :include (const _ :ServiceBase))'

        def on_class(node)
          return if super_class_declarations(node) # skip if class has parent declaration
          return if self_call_with_arg_declaration(node).any? # skip if self.call has arguments
          return if include_service_base(node).any? # skip if class already includes ServiceBase
          return if self_call_with_nested_constructors_with_arg(node).any?

          if instance_call_declarations(node).any? && self_call_with_nested_constructors(node).any?
            add_offense(node) do |corrector|
              add_servicebase(corrector, node)
              corrector.remove(self_call_with_nested_constructors(node).first)
            end

            return
          end

          return unless instance_call_declarations(node).any? || self_call_declarations(node).any?

          add_offense(node) do |corrector|
            add_servicebase(corrector, node)
            if self_call_declarations(node).any?
              self_call_node = self_call_declarations(node).first

              corrector.replace(self_call_node.child_nodes.first, '') # removes `self`
              corrector.replace(self_call_node.loc.operator, '') # removes `.`
            end
          end
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
