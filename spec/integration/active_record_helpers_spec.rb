require 'spec_helper_integration'

describe 'active record helpers spec' do
  before :each do
    Rails.cache.clear
  end

  let(:klass) { Article }
  let(:helper) { klass.arel_helper }

  # query_builder
  # arel_fn
  # arel_coalesce
  # arel_concat
  # arel_cast
  # arel_cross_join
  # arel_table_from_query
  # arel_from_with
end
