# frozen_string_literal: true

module Kaguya
  module AST
    class Node
      attr_reader :parent
      attr_reader :children
      attr_reader :type

      # @param [Symbol] type
      # @param [Node] parent
      def initialize(type:, parent:)
        @type = type
        @parent = parent
        @children = []

        @parent.children << self if @parent
      end

      # @param [Compiler] compiler
      # @return [Array]
      def accept(compiler)
        compiler.visit(self)
      end

      # @return [String]
      def to_s
        @type.to_s
      end
    end
  end
end
