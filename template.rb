# Add Dependent Gems
gem 'logstasher'

# Lock Ruby version
file '.ruby-version', '2.2.2'

# Enable JSON-formatted logging in production
application nil, env: "production" do <<-'RUBY'
config.logstasher.enabled = true
  config.logstasher.logger = Logger.new(Rails.root.join("/log/production.json.log"))
  config.logstasher.suppress_app_log = true
RUBY
end
# Remove the default log formatter
gsub_file 'config/environments/production.rb', 'config.log_formatter = ::Logger::Formatter.new', '# config.log_formatter = ::Logger::Formatter.new'

# Configure JSON-formatted logging with additional fields
initializer "logstasher.rb" do <<-'RUBY'
if Object.const_defined?('LogStasher') && LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    # Mirrors Nginx request logging, e.g GET /path/here HTTP/1.1
    fields[:request] = "\#{request.request_method} \#{request.fullpath} \#{request.headers['SERVER_PROTOCOL']}"
    # Pass request Id to logging
    fields[:govuk_request_id] = request.headers['GOVUK-Request-Id']
  end
end
RUBY
end
