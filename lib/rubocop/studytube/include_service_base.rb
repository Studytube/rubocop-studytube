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
        def_node_matcher :instance_call_declarations, '(def :call ...)'
        def_node_matcher :class_call_declarations, '(defs (self) :call ...)'

        def on_def(node)
          class_node = node.parent.class_type? && node.parent

          return unless class_node
          return if super_class_declarations(class_node)
          return if include_declarations(class_node).any? do |current|
            current.to_s.eql?('ServiceBase')
          end 

          add_offense(class_node) if instance_call_declarations(node) || class_call_declarations(node)
        end
      end
    end
  end
end
