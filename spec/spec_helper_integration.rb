ENV['RAILS_ENV'] ||= 'test'
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'dummy/config/environment'
require 'rspec/rails'
require 'generator_spec/test_case'
require 'database_cleaner'

ActiveRecord::Migration.verbose = false
ActiveRecord::Migration.maintain_test_schema!

Dir["#{File.dirname(__FILE__)}/support/{dependencies,helpers,shared}/*.rb"].each { |f| require f }

# Remove after dropping support of Rails 4.2
# require "#{File.dirname(__FILE__)}/support/http_method_shim.rb"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec

  config.infer_base_class_for_anonymous_controllers = false

  config.include RSpec::Rails::RequestExampleGroup, type: :request

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.order = 'random'
end
