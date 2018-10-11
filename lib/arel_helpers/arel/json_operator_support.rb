module Arel
  module JSONOperatorSupport
    extend ArelHelpers::AugmentArel

    JSON_NODES = %w[json_operator json_get json_get_as_text json_get_by_path json_get_by_path_as_text]

    JSONPredications = proc do
      def json_get(other)
        Arel::Nodes::JSONGet.new self, Arel::Nodes.build_quoted(other)
      end

      def json_get_as_text(other)
        Arel::Nodes::JSONGetAsText.new self, Arel::Nodes.build_quoted(other)
      end

      def json_get_by_path(*path)
        Arel::Nodes::JSONGetByPath.new self, path
      end

      def json_get_by_path_as_text(*path)
        Arel::Nodes::JSONGetByPathAsText.new self, path
      end
    end

    module JSONVisitation
      def visit_Arel_Nodes_JSONGet(o, collector)
        infix_value o, collector, ' -> '
      end

      def visit_Arel_Nodes_JSONGetAsText(o, collector)
        infix_value o, collector, ' ->> '
      end

      def visit_Arel_Nodes_JSONGetByPath(o, collector)
        infix_value o, collector, ' #> '
      end

      def visit_Arel_Nodes_JSONGetByPathAsText(o, collector)
        infix_value o, collector, ' #>> '
      end
    end

    class << self
      def insert!
        require_nodes JSON_NODES

        include_predications! JSONPredications
        include_visitor! JSONVisitation
      end
    end
  end
end
