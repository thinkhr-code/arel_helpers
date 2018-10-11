module Arel
  module Nodes
    class JSONGetByPath < JSONOperator
      operator '#>'

      # @return [Arel::Nodes::TextArray]
      def cast_right(value)
        Arel::Nodes.build_text_array(value)
      end
    end
  end
end
