require 'arel_helpers'
require 'arel_helpers/active_record_helpers'
require 'arel_helpers/augment_arel'
require 'arel_helpers/arel/text_array_support'
require 'arel_helpers/arel/json_operator_support'
require 'arel_helpers/active_record_helpers'


# @TODO Not quite sure why....
Arel::Nodes::Extract.class_eval do
  include Arel::OrderPredications
end

ActiveRecord::Base.send :include, ArelHelpers::ActiveRecordHelpers

Arel::TextArraySupport.insert!
Arel::JSONOperatorSupport.insert!

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
