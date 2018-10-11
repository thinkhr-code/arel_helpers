module Arel
  module Nodes
    class JSONOperator < Arel::Nodes::Binary
      include ActiveSupport::Configurable
      include Arel::Expressions
      include Arel::Predications
      include Arel::AliasPredication
      include Arel::Math

      def initialize(left, right)
        left  = cast_left(left)
        right = cast_right(right)

        super(left, right)
      end

      # @!attribute [r] operator
      # @return [Arel::Nodes::SqlLiteral]
      def operator
        config.operator
      end

      # @abstract
      def cast_left(value)
        value
      end

      # @abstract
      def cast_right(value)
        value
      end

      class << self
        def operator(operator = nil)
          if operator.present?
            config.operator = Arel.sql operator
          end

          config.operator
        end
      end
    end
  end
end
