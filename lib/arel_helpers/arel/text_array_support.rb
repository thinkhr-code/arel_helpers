module Arel
  module TextArraySupport
    extend ArelHelpers::AugmentArel

    ARRAY_NODES = %w[text_array]

    module TextArrayVisitation
      ARRAY_START = Arel.sql %,ARRAY[,
      ARRAY_SEP   = Arel.sql ','
      ARRAY_END   = Arel.sql %,]::text[],

      def visit_Arel_Nodes_TextArray(o, collector)
        collector << ARRAY_START

        last_index = o.value.length - 1

        o.value.each.with_index do |val, index|
          visit(val, collector)

          collector << ARRAY_SEP unless index == last_index
        end

        collector << ARRAY_END
      end
    end

    module TextArrayNodeMethods
      # @return [Arel::Nodes::TextArray]
      def build_text_array(*values)
        Arel::Nodes::TextArray.new *values
      end
    end

    class << self
      def insert!
        require_nodes ARRAY_NODES

        extend_nodes! TextArrayNodeMethods
        include_visitor! TextArrayVisitation
      end
    end
  end
end
