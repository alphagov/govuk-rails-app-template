# Include govuk-rails-app-template root in source_paths
source_paths << File.dirname(__FILE__)

gem 'unicorn', '~> 4.9.0'

run 'bundle install'
git :init
git add: "."
command = "#{File.basename($0)} #{ARGV.join(' ')}"
git commit: "-a -m 'Bare Rails application\n\nGenerated using https://github.com/alphagov/govuk-rails-app-template\nCommand: #{command}'"

# Configure JSON-formatted logging
gem 'logstasher', '0.6.5'
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

# Setup rspec
gem_group :development, :test do
  gem 'rspec-rails', '~> 3.3'
end
run 'bundle install'
generate("rspec:install")
remove_dir('test')
git add: "."
git commit: "-a -m 'Use rspec-rails for testing'"

# Lock Ruby version
file '.ruby-version', "2.2.2\n"

git add: "."
git commit: "-a -m 'Lock Ruby version'"

# Boilerplate README and LICENSE files
remove_file 'README.rdoc'
template 'templates/README.md.erb', 'README.md'
template 'templates/LICENSE.erb', 'LICENSE'

git add: "."
git commit: "-a -m 'Add README.md and LICENSE'"

# Boilerplate jenkins scripts
copy_file 'templates/jenkins.sh', 'jenkins.sh'
template  'templates/jenkins_branches.sh.erb', 'jenkins_branches.sh'
chmod 'jenkins.sh', 0755
chmod 'jenkins_branches.sh', 0755

git add: "."
git commit: "-a -m 'Add Jenkins scripts'"

# Add a healthcheck route and specs
route "get '/healthcheck', :to => proc { [200, {}, ['OK']] }"
copy_file 'templates/spec/requests/healthcheck_spec.rb', 'spec/requests/healthcheck_spec.rb'

git add: "."
git commit: "-a -m 'Add healthcheck endpoint'"

# Configure code coverage
gem_group :development, :test do
  gem 'simplecov', '0.10.0', :require => false
  gem 'simplecov-rcov', '0.2.3', :require => false
end

prepend_to_file 'spec/rails_helper.rb' do <<-'RUBY'
require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'
RUBY
end

run 'bundle install'
append_to_file '.gitignore', "/coverage\n"

git add: "."
git commit: "-a -m 'Use simplecov for code coverage reporting'"

# Add airbrake for errbit error reporting
gem 'plek', '~> 1.10'
gem 'airbrake', '~> 4.2.1'
initializer "airbrake.rb", File.read("#{File.dirname(__FILE__)}/templates/initializers/airbrake.rb")
run 'bundle install'
git add: "."
git commit: "-a -m 'Add airbrake for errbit error reporting'"
