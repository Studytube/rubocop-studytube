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
        MSG = 'please include ServiceBase into a service class'

        def_node_search :include_declarations, '(send nil? :include (:const ... $_) ...)'
        def_node_search :super_class_declarations, '(class (const nil? _) (const ...) ...)'
        def_node_search :instance_call_declarations, '(def :call ...)'
        def_node_search :class_call_declarations, '(defs (self) :call ...)'

        def on_class(node)
          return if super_class_declarations(node).any?

          return if include_declarations(node).any? do |current|
            current.to_s.eql?('ServiceBase')
          end

          add_offense(node) if instance_call_declarations(node).any? || class_call_declarations(node).any?
        end
      end
    end
  end
end
