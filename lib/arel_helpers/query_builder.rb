module ArelHelpers
  # Provides several methods for creating matchers and more complex
  # SQL expressions with Arel on a given {#klass}.
  class QueryBuilder
    # @!attribute [r] klass
    # Reference back to an ActiveRecord class.
    # @return [Class]
    attr_reader :klass

    delegate :arel_table, to: :klass

    def initialize(klass)
      @klass = klass
    end

    # @!group Functions
    # @param [String] name name of the function
    # @param [Object...] args
    # @return [Arel::Nodes::NamedFunction]
    def function(name, *args)
      Arel::Nodes::NamedFunction.new name, args
    end

    alias_method :fn, :function

    # SQL Coalesce function
    # @return [Arel::Nodes::NamedFunction]
    def coalesce(*args)
      coerced_args = map_strings_to_quoted_nodes *args

      fn 'COALESCE', *coerced_args
    end

    def concat(*args)
      coerced_args = map_strings_to_quoted_nodes *args

      fn 'CONCAT', *coerced_args
    end
    # @!endgroup

     # @return [Arel::Nodes::Case]
     def case_expr(&block)
       expr = Arel::Nodes::Case.new

       yield expr if block_given?

       expr
     end

    def arel_quote(quotable)
      Arel::Nodes.build_quoted quotable
    end

    # @!group Expressions
    # @TODO This is mostly the same as Arel::Nodes.build_text_array *items`
    # Cast an array to a PG array
    # @param [<String, Integer, Symbol>] items
    # @return [String]
    def cast_as_array(items)
      items.map do |item|
        if item.is_a?(String) || item.is_a?(Symbol)
          "('#{ item.to_s }')"
        else
          "(#{ item })"
        end
      end.join(', ')
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @return [Arel::Nodes::Equality(Arel::Attribute, nil)]
    def is_null(column)
      column = ensure_arel_attribute! column

      column.eq(nil)
    end

    # @param [Arel::Attribute, Arel::Node, Symbol, String] column
    # @return [Arel::Nodes::NamedFunction]
    def count_by_boolean(column)
      column = ensure_arel_attribute! column

      fn('COUNT', case_expr.when(column).then(1))
    end

    # @param [Arel::Attribute, Symbol, String] column
    # @param [Hash] options
    # @option options [Integer, String, Boolean] truthy
    # @option options [Integer, String, Boolean] falsey
    # @return [Arel::Nodes::Sum]
    def sum_by_boolean(attr, options = {})
      attr = ensure_arel_attribute! attr

      truthy = options.fetch :truthy, 1
      falsey = options.fetch :falsey, 0

      Arel::Nodes::Sum.new [case_expr.when(attr).then(truthy).else(falsey)]
    end
    # @!endgroup

    # @!group Dates
    # @param [Symbol, String, Arel::Attribute] column
    # @param [:asc, :desc] direction
    # @return [Array<Integer>]
    def extract_years_from(column, direction: :desc, scope: klass.all)
      column = ensure_arel_attribute! column

      plucked_years = order_by(column.extract(:year), direction, scope).distinct.pluck(column.extract(:year).to_sql)

      Array(plucked_years).map(&:to_i)
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [Integer] date  (ex. \`30.days\`)
    # @return [Arel::Nodes::GreaterThanOrEqual]
    def date_since(column, date)
      column = ensure_arel_attribute! column

      since_time = (Time.now - date).beginning_of_day.iso8601

      column.gteq since_time
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [Integer] year
    # @return [Arel::Nodes::Between]
    def date_in_year(column, year)
      column = ensure_arel_attribute! column

      year_start  = Date.new year
      year_end    = year_start.end_of_year

      column.in(year_start..year_end)
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [Time] date
    # @return [Arel::Nodes::LessThanOrEqual]
    def date_before(column, date)
      column = ensure_arel_attribute! column

      column.lteq date
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [String] interval '6 months'
    # @return [Arel::Nodes::GreaterThanOrEqual]
    def date_before_interval(column, interval)
      column = ensure_arel_attribute! column

      column.lteq interval_from_now(interval)
    end

    def earlier_entries(column, date, id)
      column = ensure_arel_attribute! column
      id_column = ensure_arel_attribute! :id

      # If the dates are equal, then we want to get only entries with lower IDs
      column.lt(date).or(column.eq(date).and(id_column.lt(id)))
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @return [Arel::Nodes::LessThanOrEqual]
    def date_before_now(column)
      date_before column, Time.now
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [Time] date
    # @return [Arel::Nodes::GreaterThanOrEqual]
    def date_after(column, date)
      column = ensure_arel_attribute! column

      column.gteq date
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [String] interval '6 months'
    # @return [Arel::Nodes::GreaterThanOrEqual]
    def date_after_interval(column, interval)
      column = ensure_arel_attribute! column

      column.gteq interval_from_now(interval)
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [Time] min_date
    # @param [Time] max_date
    # @return [Arel::Nodes::GreaterThanOrEqual]
    def date_between(column, min_date, max_date)
      column = ensure_arel_attribute! column

      column.between min_date..max_date
    end

    def later_entries(column, date, id)
      column = ensure_arel_attribute! column
      id_column = ensure_arel_attribute! :id

      # If the dates are equal, then we want to get only entries with higher IDs
      column.gt(date).or(column.eq(date).and(id_column.gt(id)))
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @return [Arel::Nodes::GreaterThanOrEqual]
    def date_after_now(column)
      date_after column, Time.now
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [Time] date
    # @return [Arel::Nodes::Or(Arel::Nodes::Equality, Arel::Nodes::LessThanOrEqual)]
    def date_null_or_before(column, date)
      is_null(column).or(date_before(column, date))
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @return [Arel::Nodes::Or(Arel::Nodes::Equality, Arel::Nodes::LessThanOrEqual)]
    def date_null_or_before_now(column)
      is_null(column).or(date_before_now(column))
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [Time] date
    # @return [Arel::Nodes::Or(Arel::Nodes::Equality, Arel::Nodes::GreaterThanOrEqual)]
    def date_null_or_after(column, date)
      is_null(column).or(date_after(column, date))
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @return [Arel::Nodes::Or(Arel::Nodes::Equality, Arel::Nodes::GreaterThanOrEqual)]
    def date_null_or_after_now(column)
      is_null(column).or(date_after_now(column))
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @param [Time] date
    def date_on_day(column, date)
      column = ensure_arel_attribute! column
      parsed = ensure_time date

      beginning = parsed.beginning_of_day
      ending = parsed.end_of_day

      date_after(column, beginning).and(date_before(column, ending))
    end
    # @!endgroup


    # @param [<Integer,String>] ids
    # @param [Arel::Attribute] column
    # @return [Arel::Nodes::NamedFunction('idx', (Arel::Nodes::SqlLiteral, Arel::Attribute))]
    def arel_array_position_fn(ids, column, quoted: false)
      if quoted
        ids = ids.map { |id| Arel::Nodes.build_quoted(id).to_sql }
      end
      function 'array_position', [arel_ids_to_pg_array(ids), column]
    end

    # @param [<Integer>] ids
    # @param [Arel::Attribute] column
    # @return [Arel::Nodes::NamedFunction('idx', (Arel::Nodes::SqlLiteral, Arel::Attribute))]
    def arel_idx_fn(ids, column = arel_table[:id])
      function 'idx', [arel_ids_to_pg_array(ids), column]
    end

    private

    # @param [Symbol, String, Arel::Attribute] column
    # @param [:asc, :desc, String, Symbol] direction
    # @param [ActiveRecord::Relation] scope
    # @return [ActiveRecord::Relation]
    def order_by(column, direction, scope = klass.all)
      order_scope = \
        case direction
        when :asc, /^asc/i    then column.asc
        when :desc, /^desc/i  then column.desc
        else column
        end

      scope.order(order_scope)
    end

    # @param [Symbol, String, Arel::Attribute] column
    # @return [Arel::Attribute]
    def ensure_arel_attribute!(column)
      case column
      when Arel::Attribute, Arel::Node then column
      when String, Symbol   then arel_table[column]
      else arel_table[column.to_s]
      end
    end

    # @param [Time, DateTime, String, Integer] date
    # @return [Time]
    def ensure_time(date)
      if date.is_a?(Time) || date.is_a?(DateTime)
        date
      else
        Time.parse(date)
      end
    end

    # @param [String] string
    # @return [Arel::Nodes::SqlLiteral]
    def interval_from_now(string)
      quoted_interval = Arel::Nodes.build_quoted string
      Arel::Nodes::SqlLiteral.new "CURRENT_TIMESTAMP - INTERVAL #{ quoted_interval.to_sql }"
    end

    # @param [<Integer,String>] ids
    # @return [Arel::Nodes::SqlLiteral]
    def arel_ids_to_pg_array(ids)
      Arel.sql 'ARRAY[%s]' % ( ids * ',' )
    end

    def map_strings_to_quoted_nodes(*args)
      args.map do |arg|
        if arg.is_a? String
          arel_quote arg
        else
          arg
        end
      end
    end
  end
end
