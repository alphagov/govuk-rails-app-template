# Include govuk-rails-app-template root in source_paths
source_paths << File.dirname(__FILE__)

gem 'unicorn', '~> 4.9.0'

run 'bundle install'
git :init
git add: "."
command = "#{File.basename($0)} #{ARGV.join(' ')}"
git commit: "-a -m 'Bare Rails application\n\nGenerated using https://github.com/alphagov/govuk-rails-app-template\nCommand: #{command}'"

# Configure JSON-formatted logging
gem 'logstasher', '0.6.2' # 0.6.5+ change the json schema used for events
run 'bundle install'
# Enable JSON-formatted logging in production
environment nil, env: "production" do <<-'RUBY'
config.logstasher.enabled = true
  config.logstasher.logger = Logger.new(Rails.root.join("log/production.json.log"))
  config.logstasher.suppress_app_log = true
RUBY
end
# Remove the default log formatter
gsub_file 'config/environments/production.rb', 'config.log_formatter = ::Logger::Formatter.new', '# config.log_formatter = ::Logger::Formatter.new'

# Configure JSON-formatted logging with additional fields
initializer "logstasher.rb", File.read("#{File.dirname(__FILE__)}/templates/initializers/logstasher.rb")

git add: "."
git commit: "-a -m 'Use logstasher for JSON-formatted logging in production'"

# Add deprecated_columns (assumes a DB exists for at least the users table)
gem 'deprecated_columns'
run 'bundle install'
git add: "."
git commit: "-a -m 'Add deprecated_columns to guide removing DB columns'"

# Setup rspec and useful testing tools
gem_group :development, :test do
  gem 'rspec-rails', '~> 3.3'
  gem 'webmock', require: false
  gem 'timecop'
  gem "factory_girl_rails", "4.7.0"
end
run 'bundle install'
generate("rspec:install")
remove_file 'spec/spec_helper.rb'
remove_file 'spec/rails_helper.rb'
copy_file 'templates/spec/spec_helper.rb', 'spec/spec_helper.rb'
copy_file 'templates/spec/rails_helper.rb', 'spec/rails_helper.rb'
remove_dir('test')
git add: "."
git commit: "-a -m 'Add rspec-rails and useful testing tools'"

# Add GDS-SSO
gem "gds-sso", "12.1.0"
gem 'plek', '~> 1.10'
copy_file 'templates/initializers/gds-sso.rb', 'config/initializers/gds-sso.rb'
copy_file 'templates/spec/support/authentication_helper.rb', 'spec/support/authentication_helper.rb'
inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-'RUBY'
  include GDS::SSO::ControllerMethods

  before_action :require_signin_permission!
RUBY
end
copy_file 'templates/app/models/user.rb', 'app/models/user.rb'
copy_file 'templates/spec/factories/user.rb', 'spec/factories/user.rb'
copy_file 'templates/db/migrate/20160622154200_create_users.rb', 'db/migrate/20160622154200_create_users.rb'
run 'bundle install'
system("bundle exec rake db:create:all")
system("bundle exec rake db:migrate")
system("bundle exec rake db:test:prepare")

# Add govuk-lint
gem_group :development, :test do
  gem 'govuk-lint'
end
run 'bundle install'
git add: "."
git commit: "-a -m 'Add govuk-lint for enforcing GOV.UK styleguide'"

# Lock Ruby version
file '.ruby-version', "2.3.0\n"
prepend_to_file('Gemfile') { "ruby File.read('.ruby-version').strip\n" }

git add: "."
git commit: "-a -m 'Lock Ruby version'"

# Boilerplate README and LICENSE files
remove_file 'README.rdoc'
template 'templates/README.md.erb', 'README.md'
template 'templates/LICENSE.erb', 'LICENSE'

git add: "."
git commit: "-a -m 'Add README.md and LICENSE'"

# Boilerplate jenkins scripts
template 'templates/jenkins.sh.erb', 'jenkins.sh'
chmod 'jenkins.sh', 0755

git add: "."
git commit: "-a -m 'Add Jenkins scripts'"

# Add a healthcheck route and specs
route "get '/healthcheck', to: proc { [200, {}, ['OK']] }"
copy_file 'templates/spec/requests/healthcheck_spec.rb', 'spec/requests/healthcheck_spec.rb'

git add: "."
git commit: "-a -m 'Add healthcheck endpoint'"

# Configure code coverage
gem_group :development, :test do
  gem 'simplecov', '0.10.0', :require => false
  gem 'simplecov-rcov', '0.2.3', :require => false
end

prepend_to_file 'spec/rails_helper.rb' do <<-'RUBY'
if ENV["RCOV"]
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start 'rails'
end
RUBY
end

run 'bundle install'
append_to_file '.gitignore', "/coverage\n"

git add: "."
git commit: "-a -m 'Use simplecov for code coverage reporting'"

# Add airbrake for errbit error reporting
gem 'airbrake', '~> 4.2.1'
initializer "airbrake.rb", File.read("#{File.dirname(__FILE__)}/templates/initializers/airbrake.rb")
run 'bundle install'
git add: "."
git commit: "-a -m 'Add airbrake for errbit error reporting'"

# Add common debuggers
gem_group :development, :test do
  gem 'pry'
  gem 'byebug'
end

prepend_to_file 'spec/rails_helper.rb' do <<-'RUBY'
require "pry"
require "byebug"
RUBY
end

run 'bundle install'
git add: "."
git commit: "-a -m 'Add common debuggers'"
