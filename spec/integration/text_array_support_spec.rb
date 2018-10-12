require 'spec_helper_integration'

describe 'text_array_support spec' do
  it 'works' do
    items = ['foo', 'bar', 2, Article.arel_table[:id]]
    expect(Arel::Nodes.build_text_array(*items).to_sql).to eq("ARRAY['foo','bar',2,\"articles\".\"id\"]::text[]")
  end
end
