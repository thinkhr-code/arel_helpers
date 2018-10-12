require 'active_support'
require 'active_support/core_ext'
require 'active_support/concern'
require 'active_support/configurable'
require 'active_record'
require 'arel'

require 'arel_helpers/active_record_helpers'
require 'arel_helpers/augment_arel'
require 'arel_helpers/arel/text_array_support'
require 'arel_helpers/arel/json_operator_support'
require 'arel_helpers/active_record_helpers'
require 'arel_helpers/version'

module ArelHelpers
  class << self
    def bootstrap!
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
