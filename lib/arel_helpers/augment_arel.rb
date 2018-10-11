module ArelHelpers
  # Extended by modules that themselves augment arel
  module AugmentArel
    def require_nodes(*nodes)
      nodes.flatten!

      nodes.each do |node|
        require_relative './arel/nodes/' + node.to_s
      end
    end

    def extend_nodes!(mod)
      Arel::Nodes.extend mod
    end

    def include_predications!(callable)
      Arel::Predications.class_eval(&callable)
    end

    def include_visitor!(mod)
      Arel::Visitors::PostgreSQL.include mod
    end
  end
end
