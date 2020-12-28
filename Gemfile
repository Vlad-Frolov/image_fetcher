# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'pry', '~> 0.13.1'
gem 'rubocop', '~> 1.7'
gem 'byebug'

group :test do
  gem 'rspec', '~> 3.0'
  gem 'webmock', '~> 3.11'
end
