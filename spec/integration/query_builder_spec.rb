require 'spec_helper_integration'

# @NOTE This suite assumes we are using PG quoting and dates

describe 'query builder spec' do
  before :each do
    Rails.cache.clear
  end

  let(:klass) { Article }
  let(:helper) { klass.arel_helper }
  let(:arel_table) { klass.arel_table }
  let(:date_column) { :published_at }
  let(:current_date) { Date.today }
  let(:current_year) { current_date.year }

  describe '#klass' do
    it 'should refer back to the associated class' do
      expect(helper.klass).to eq klass
    end
  end

  describe '#function' do
    let(:function_expression) { helper.function('SOMEFN', 0, 1, 2) }

    it 'should create a function node' do
      expect(function_expression).to be_a Arel::Nodes::NamedFunction
    end

    it 'should generate the correct SQL' do
      expect(function_expression.to_sql).to eq('SOMEFN(0, 1, 2)')
    end
  end

  describe '#coalesce' do
    let(:function_expression) { helper.coalesce arel_table[:id], 2, 'foo' }

    it 'should create a function node' do
      expect(function_expression).to be_a Arel::Nodes::NamedFunction
    end

    it 'should generate the correct SQL' do
      expect(function_expression.to_sql).to eq('COALESCE("articles"."id", 2, \'foo\')')
    end
  end

  describe '#concat' do
    let(:function_expression) { helper.concat arel_table[:id], 2, 'foo' }

    it 'should create a function node' do
      expect(function_expression).to be_a Arel::Nodes::NamedFunction
    end

    it 'should generate the correct SQL' do
      expect(function_expression.to_sql).to eq('CONCAT("articles"."id", 2, \'foo\')')
    end
  end

  describe '#case_expr' do
    let(:function_expression) { helper.case_expr }

    it 'should return a case node' do
      expect(function_expression).to be_a Arel::Nodes::Case
    end
  end

  describe '#arel_quote' do
    let(:function_expression) { helper.arel_quote 'foo' }

    it 'should be an arel node' do
      expect(function_expression).to be_a Arel::Nodes::Quoted
    end

    it 'should generate the correct SQL' do
      expect(function_expression.to_sql).to eq("'foo'")
    end
  end

  describe '#cast_as_array' do
    let(:function_expression) { helper.cast_as_array [1, 'foo', :bar] }

    it 'should generate the right SQL' do
      expect(function_expression).to eq("(1), ('foo'), ('bar')")
    end
  end

  describe '#is_null' do
    let(:function_expression) { helper.is_null :published_at }

    it 'should be an arel node' do
      expect(function_expression).to be_a Arel::Nodes::Equality
    end

    it 'should generate the right SQL' do
      expect(function_expression.to_sql).to eq('"articles"."published_at" IS NULL')
    end
  end

  describe '#count_by_boolean' do
    let(:function_expression) { helper.count_by_boolean :published_at }

    it 'should be an arel node' do
      expect(function_expression).to be_a Arel::Nodes::NamedFunction
    end

    it 'should generate the right SQL' do
      expect(function_expression.to_sql).to eq('COUNT(CASE WHEN "articles"."published_at" THEN 1 END)')
    end
  end

  describe '#sum_by_boolean' do
    let(:sum_expression) { helper.sum_by_boolean :featured }

    it 'should create a sum expression' do
      expect(sum_expression).to be_a Arel::Nodes::Sum
    end

    it 'generates the correct SQL' do
      expect(sum_expression.to_sql).to eq('SUM(CASE WHEN "articles"."featured" THEN 1 ELSE 0 END)')
    end
  end

  describe '#extract_years_from' do
    let(:sum_expression) { helper.extract_years_from(date_column) }

    before(:each) do
      Article.create! published_at: Date.today
    end

    it 'returns the correct dates' do
      expect(sum_expression).to eq([current_year])
    end
  end

  describe '#date_since' do
    let(:sum_expression) { helper.date_since date_column, 30.days }

    it 'should return an array' do
      expect(sum_expression).to be_an Arel::Nodes::GreaterThanOrEqual
    end

    it 'generates the correct SQL' do
      expect(sum_expression.to_sql).to eq("\"articles\".\"published_at\" >= '#{ (Date.today - 30.days).rfc3339 }'")
    end
  end

  describe '#date_in_year' do
    let(:date_expression) { helper.date_in_year date_column, current_year }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::Between
    end

    it 'generates the correct SQL' do
      start_date = Date.today.beginning_of_year.to_s
      end_date =Date.today.end_of_year.to_s

      expect(date_expression.to_sql).to eq("\"articles\".\"published_at\" BETWEEN '#{ start_date }' AND '#{ end_date }'")
    end
  end

  describe '#date_before' do
    let(:date_expression) { helper.date_before date_column, current_date }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::LessThanOrEqual
    end

    it 'generates the correct SQL' do
      expect(date_expression.to_sql).to eq("\"articles\".\"published_at\" <= '#{ Date.today }'")
    end
  end

  describe '#date_before_interval' do
    let(:date_expression) { helper.date_before_interval date_column, 30.days }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::LessThanOrEqual
    end

    it 'generates the correct SQL' do
      expect(date_expression.to_sql).to eq("\"articles\".\"published_at\" <= CURRENT_TIMESTAMP - INTERVAL 2592000")
    end
  end

  describe '#earlier_entries' do
    let(:date_expression) { helper.earlier_entries date_column, 30.days.ago.to_date, 15 }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::Grouping
    end

    it 'generates the correct SQL' do
      date = 30.days.ago.to_date.to_s

      expect(date_expression.to_sql).to eq("(\"articles\".\"published_at\" < '#{ date }' OR \"articles\".\"published_at\" = '#{ date }' AND \"articles\".\"id\" < 15)")
    end
  end

  describe '#date_before_now' do
    let(:date_expression) { helper.date_before_now date_column }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::LessThanOrEqual
    end

    it 'should compile to valid SQL' do
      # Because timestamps in PG are hard
      expect(date_expression.to_sql).to include("\"articles\".\"published_at\" <= '#{ Date.today.to_s }")
    end
  end

  describe '#date_after' do
    let(:date_expression) { helper.date_after date_column, current_date }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::GreaterThanOrEqual
    end

    it 'generates the correct SQL' do
      expect(date_expression.to_sql).to eq("\"articles\".\"published_at\" >= '#{ Date.today }'")
    end
  end

  describe '#date_after_interval' do
    let(:date_expression) { helper.date_after_interval date_column, 30.days }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::GreaterThanOrEqual
    end

    it 'generates the correct SQL' do
      expect(date_expression.to_sql).to eq("\"articles\".\"published_at\" >= CURRENT_TIMESTAMP - INTERVAL 2592000")
    end
  end

  describe '#date_between' do
    let(:date_expression) { helper.date_between date_column, 30.days.ago.to_date, Date.today }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::Between
    end

    it 'generates the correct SQL' do
      min_date = 30.days.ago.to_date.to_s
      max_date = Date.today.to_s

      expect(date_expression.to_sql).to eq("\"articles\".\"published_at\" BETWEEN '#{ min_date }' AND '#{ max_date }'")
    end
  end

  describe '#later_entries' do
    let(:date_expression) { helper.later_entries date_column, 30.days.ago.to_date, 15 }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::Grouping
    end

    it 'generates the correct SQL' do
      date = 30.days.ago.to_date.to_s

      expect(date_expression.to_sql).to eq("(\"articles\".\"published_at\" > '#{ date }' OR \"articles\".\"published_at\" = '#{ date }' AND \"articles\".\"id\" > 15)")
    end
  end

  describe '#date_after_now' do
    let(:date_expression) { helper.date_after_now date_column }

    it 'should return a proper node' do
      expect(date_expression).to be_a Arel::Nodes::GreaterThanOrEqual
    end

    it 'generates the correct SQL' do
      # Because timestamps in PG are hard
      expect(date_expression.to_sql).to include("\"articles\".\"published_at\" >= '#{ Date.today.to_s }")
    end
  end

  describe '#date_null_or_before' do
  end

  describe '#date_null_or_before_now' do
  end

  describe '#date_null_or_after' do
  end

  describe '#date_null_or_after_now' do
  end

  describe '#date_on_day' do
  end
end
