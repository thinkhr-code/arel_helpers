require_relative './active_record_helpers'
require_relative './augment_arel'
require_relative './arel/text_array_support'
require_relative './arel/json_operator_support'
require_relative './active_record_helpers'

module ArelHelpers
  class Railtie < Rails::Railtie
    initializer 'arel_helpers.bootstrap_active_record' do
      # @TODO Not quite sure why....
      Arel::Nodes::Extract.class_eval do
        include Arel::OrderPredications
      end

      ActiveRecord::Base.send :include, ArelHelpers::ActiveRecordHelpers

      Arel::TextArraySupport.insert!
      Arel::JSONOperatorSupport.insert!
    end
  end
end
