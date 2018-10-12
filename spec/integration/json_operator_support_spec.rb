require 'spec_helper_integration'

describe 'json_opperator_support spec' do
  let(:klass) { Article }
  let(:table) { klass.arel_table }

  describe('#json_get') do
    let(:expression) { table[:id].json_get 'foo' }

    it 'should return a proper node' do
      expect(expression).to be_a Arel::Nodes::JSONGet
    end

    it 'generates the correct SQL' do
      expect(expression.to_sql).to eq("\"articles\".\"id\" -> 'foo'")
    end
  end

  describe('#json_get_as_text') do
    let(:expression) { table[:id].json_get_as_text 'foo' }

    it 'should return a proper node' do
      expect(expression).to be_a Arel::Nodes::JSONGetAsText
    end

    it 'generates the correct SQL' do
      expect(expression.to_sql).to eq("\"articles\".\"id\" ->> 'foo'")
    end
  end

  describe('#json_get_by_path') do
    let(:expression) { table[:id].json_get_by_path 'foo', 'bar', 'baz' }

    it 'should return a proper node' do
      expect(expression).to be_a Arel::Nodes::JSONGetByPath
    end

    it 'generates the correct SQL' do
      expect(expression.to_sql).to eq("\"articles\".\"id\" #> ARRAY['foo','bar','baz']::text[]")
    end
  end

  describe('#json_get_by_path_as_text') do
    let(:expression) { table[:id].json_get_by_path_as_text 'foo', 'bar', 'baz' }

    it 'should return a proper node' do
      expect(expression).to be_a Arel::Nodes::JSONGetByPathAsText
    end

    it 'generates the correct SQL' do
      expect(expression.to_sql).to eq("\"articles\".\"id\" #>> ARRAY['foo','bar','baz']::text[]")
    end
  end
end
