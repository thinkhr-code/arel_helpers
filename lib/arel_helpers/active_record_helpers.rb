require_relative './query_builder'

module ArelHelpers
  module ActiveRecordHelpers
    extend ActiveSupport::Concern

    AREL_NOW = Arel::Nodes::NamedFunction.new 'NOW', []

    # These are methods that are made available on ActiveRecord itself.  These are useful especially in scopes.
    # @TODO Ideal is to migrate all of these to the `query_builder` so that we are not polluting ActiveRecord
    module ClassMethods
      # unloadable

      # Access to the query builder
      def query_builder
        @query_builder ||= ArelHelpers::QueryBuilder.new self
      end

      alias_method :arel_helper, :query_builder

      # @param [String] name name of the function
      # @param [Object...] args
      # @return [Arel::Nodes::NamedFunction]
      def arel_fn(name, *args)
        query_builder.function(name, *args)
      end

      def arel_coalesce(*args)
        query_builder.coalesce(*args)
      end

      def arel_concat(*args)
        query_builder.concat(*args)
      end

      # Generates a SQL-compliant `CAST(thing AS type)` sequence.
      #
      # @param [Arel::Attribute, Arel::Node, Object] thing non-Arel objects will be wrapped with `Arel::Nodes.build_quoted`
      # @param [Arel::Nodes::SqlLiteral, String, Symbol] type strings / symbols will be wrapped with `Arel.sql`
      # @return [Arel::Nodes::NamedFunction('CAST', Arel::Nodes::As(Arel::Node, Arel::Nodes::SqlLiteral))]
      def arel_cast(thing, type)
        thing = Arel::Nodes.build_quoted(thing)
        type  = Arel.sql(type.to_s) if type.is_a?(String) || type.is_a?(Symbol)

        cast_body = Arel::Nodes::As.new(thing, type)

        arel_fn 'CAST', cast_body
      end

      # Builds a SQL `CROSS JOIN` (creating the cartesian product of two or more tables).
      #
      # @param [Arel::Table, ActiveRecord::Base, String, Symbol, #table_name] against
      # @return [Arel::Nodes::SqlLiteral]
      def arel_cross_join(against)
        table_name = case against
                    when Arel::Nodes::TableAlias
                      # will cross join directly against the node
                      return Arel.sql %[CROSS JOIN #{against.to_sql}]
                    when Arel::Table       then against.name
                    when Dux[:table_name]  then against.table_name
                    when String, Symbol    then against.to_s
                    else
                      raise TypeError, "Don't know how to make a CROSS JOIN against #{against.inspect}"
                    end

        quoted_table_name = connection.quote_table_name(table_name)

        Arel.sql %[CROSS JOIN #{quoted_table_name}]
      end

      # Builds a table suitable for use as a join or a `FROM`.
      #
      # @param [Arel::SelectManager] query
      # @param [String] table_name
      # @return [(Arel::Nodes::TableAlias, Arel::Table)] we have to return two things, one that can be used for references
      #   and one that can be used for joining, since Arel apparently doesn't to know how to visit a joined SelectManager
      def arel_table_from_query(query, table_name)
        #Arel::Nodes::TableAlias.new Arel::Nodes::Grouping.new(Arel.sql(query.to_sql)), table_name.to_s

        joins = Arel::Nodes::TableAlias.new Arel::Nodes::Grouping.new(Arel.sql(query.to_sql)), table_name.to_s
        refs  = Arel::Table.new table_name.to_s

        [joins, refs]
      end

      # This is useful for generating an arel select on very simple statements from a with query
      # (Especially important since in Arel 5 `in(String)` no longer works)
      #
      # @param [<Symbol,String>] keys
      # @param [Symbol,String] table_name
      # @return [Arel::SelectManager]
      def arel_from_with(keys:, table_name:)
        table = Arel::Table.new table_name

        table.project(*keys)
      end
    end
  end
end
