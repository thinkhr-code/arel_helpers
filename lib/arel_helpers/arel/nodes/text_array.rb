module Arel
  module Nodes
    class TextArray < Arel::Nodes::Unary
      include Arel::Predications

      def initialize(*values)
        values = values.flatten.map do |value|
          Arel::Nodes.build_quoted value
        end

        super(values)
      end
    end
  end
end
