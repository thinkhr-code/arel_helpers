module Arel
  module Nodes
    class JSONGetByPathAsText < Arel::Nodes::JSONGetByPath
      operator '#>>'
    end
  end
end
