require 'spec_helper_integration'

describe 'active record helpers spec' do
  before :each do
    Rails.cache.clear
  end

  let(:klass) { Article }
  let(:table) { klass.arel_table }
  let(:column) { table[:id] }

  describe('#arel_cast') do
    it 'creates the correct SQL' do
      expect(klass.arel_cast(column, 'String').to_sql).to eq('CAST("articles"."id" AS String)')
    end

    it 'accepts an arel node for the type input' do
      type = Arel.sql 'String'
      expect(klass.arel_cast(column, type).to_sql).to eq('CAST("articles"."id" AS String)')
    end
  end

  describe('#arel_cross_join') do
    it 'generates the correct SQL with an ActiveRecord query' do
      expect(klass.arel_cross_join(Author.where('id: 123')).to_s).to eq('CROSS JOIN "authors"')
    end

    it 'generates the correct SQL with a string' do
      expect(klass.arel_cross_join('authors').to_s).to eq('CROSS JOIN "authors"')
    end

    it 'generates the correct SQL with an arel table' do
      expect(klass.arel_cross_join(Author.arel_table).to_s).to eq('CROSS JOIN "authors"')
    end

    it 'generates the correct SQL with a table' do
      table = Arel::Table.new 'authors'

      expect(klass.arel_cross_join(table).to_s).to eq('CROSS JOIN "authors"')
    end

    it 'generates the correct SQL with a table alias' do
      node = Arel::Nodes::Grouping.new Arel.sql('1 AS t')
      table = Arel::Nodes::TableAlias.new node, 'authors'

      expect(klass.arel_cross_join(table).to_s).to eq('CROSS JOIN (1 AS t) "authors"')
    end
  end

  describe('#arel_table_from_query') do
    subject do
      query = Author.where id: 123
      klass.arel_table_from_query query, 'foo'
    end

    it 'returns the sub-select' do
      expect(subject[0].to_sql).to eq('(SELECT "authors".* FROM "authors" WHERE "authors"."id" = 123) "foo"')
    end

    it 'returns the correct class for the sub-select' do
      expect(subject[0]).to be_a Arel::Nodes::TableAlias
    end

    it 'returns the correct table' do
      expect(subject[1]).to be_an Arel::Table
    end

    it 'returns the correct table name' do
      expect(subject[1].name).to eq('foo')
    end
  end

  describe('#arel_from_with') do
    subject do
      klass.arel_from_with keys: [:id, :published_at], table_name: 'foo'
    end

    it 'returns the correct class' do
      expect(subject).to be_a Arel::SelectManager
    end

    it 'generates the correct SQL' do
      expect(subject.to_sql).to eq('SELECT id, published_at FROM "foo"')
    end
  end
end
