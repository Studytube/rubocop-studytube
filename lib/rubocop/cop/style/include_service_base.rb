# frozen_string_literal: true

module Rubocop
  module Cop
    module Style
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
      class IncludeServiceBase < RuboCop::Cop::Cop
        MSG = 'please include ServiceBase into a service class'

        def_node_search :include_declarations, '(send nil? :include (:const nil? $_) ...)'
        def_node_search :super_class_declarations, '(class (const nil? _) (const ...) ...)'

        def on_class(node)
          return if super_class_declarations(node).any?

          return if include_declarations(node).any? do |current|
            current.to_s.eql?('ServiceBase')
          end

          add_offense(node)
        end
      end
    end
  end
end
