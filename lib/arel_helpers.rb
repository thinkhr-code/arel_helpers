require 'active_support'
require 'active_support/core_ext'
require 'active_support/concern'
require 'active_support/configurable'
require 'active_record'
require 'arel'

require 'arel_helpers/active_record_helpers'
require 'arel_helpers/version'
require 'arel_helpers/railtie' if defined?(Rails::Railtie)

module ArelHelpers
end
