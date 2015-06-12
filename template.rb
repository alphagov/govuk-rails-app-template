# Include govuk-rails-app-template root in source_paths
source_paths << File.dirname(__FILE__)

# Add Dependent Gems
gem 'logstasher'

# Setup rspec
gem_group :development, :test do
  gem 'rspec-rails'
end
generate(:"rspec:install")
remove_dir('test')

# Lock Ruby version
file '.ruby-version', '2.2.2'

# Boilerplate README and LICENSE files
remove_file 'README.rdoc'
template 'templates/README.md.erb', 'README.md'
template 'templates/LICENSE.erb', 'LICENSE'

# Boilerplate jenkins scripts
copy_file 'templates/jenkins.sh', 'jenkins.sh'
template  'templates/jenkins_branches.sh.erb', 'jenkins_branches.sh'

# Add a healthcheck route and specs
route "get '/healthcheck', :to => proc { [200, {}, ['OK']] }"
copy_file 'templates/spec/requests/healthcheck_spec.rb', 'spec/requests/healthcheck_spec.rb'

# Enable JSON-formatted logging in production
environment nil, env: "production" do <<-'RUBY'
config.logstasher.enabled = true
  config.logstasher.logger = Logger.new(Rails.root.join("/log/production.json.log"))
  config.logstasher.suppress_app_log = true
RUBY
end
# Remove the default log formatter
gsub_file 'config/environments/production.rb', 'config.log_formatter = ::Logger::Formatter.new', '# config.log_formatter = ::Logger::Formatter.new'

# Configure JSON-formatted logging with additional fields
initializer "logstasher.rb", File.read("#{File.dirname(__FILE__)}/templates/initializers/logstasher.rb")
