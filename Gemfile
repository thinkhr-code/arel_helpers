source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in arel_helpers.gemspec
gemspec

group :test, :development do
  gem 'rails', '~> 5.0.0'
  gem 'pg', '~> 0.20.0'
  gem 'pry-rails', '~> 0.3.2'
  gem 'jazz_hands2', git: 'https://github.com/shaicoleman/jazz_hands2', ref: 'rails5'
end
