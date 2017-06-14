class GovukRailsTemplate
  def initialize(app)
    @app = app
    @instructions = []

    app.source_paths << File.dirname(File.expand_path("..", __FILE__))
  end

  def apply; end

  def print_instructions
    return if instructions.empty?

    block_width = 30

    puts
    puts "=" * block_width

    puts "POST-BUILD INSTRUCTIONS"

    puts "=" * block_width
    puts instructions.join("\n" + ("-" * block_width) + "\n")
    puts "=" * block_width
  end

private

  attr_reader :app
  attr_accessor :instructions

  def create_bare_rails_app
    app.run "bundle install"
    app.git :init
    app.git add: "."
    command = "#{File.basename($0)} #{ARGV.join(' ')}"
    commit "Bare Rails application\n\nGenerated using https://github.com/alphagov/govuk-rails-app-template\nCommand: #{command}"
  end

  def add_gemfile
    app.remove_file "Gemfile"
    app.copy_file "templates/Gemfile", "Gemfile"
    app.run "bundle install"
    commit "Start with a lean Gemfile"
  end

  def add_json_logging
    add_gem "logstasher", "0.6.2" # 0.6.5+ change the json schema used for events
    app.run "bundle install"

    # Enable JSON-formatted logging in production
    app.environment nil, env: "production" do <<-'RUBY'
  config.logstasher.enabled = true
  config.logstasher.logger = Logger.new(Rails.root.join("log/production.json.log"))
  config.logstasher.suppress_app_log = true
RUBY
    end

    # Remove the default log formatter
    app.gsub_file "config/environments/production.rb", "config.log_formatter = ::Logger::Formatter.new", "# config.log_formatter = ::Logger::Formatter.new"

    # Configure JSON-formatted logging with additional fields
    app.copy_file "templates/config/initializers/logstasher.rb", "config/initializers/logstasher.rb"

    app.git add: "."
    commit "Use logstasher for JSON-formatted logging in production"
  end

  def setup_database
    return if @database_created

    add_test_gem "sqlite3", comment: "Remove this when you choose a production database"
    add_gem "database_cleaner"
    add_gem "deprecated_columns"

    app.run "bundle install"

    system("bundle exec rake db:create:all")
    system("bundle exec rake db:migrate")
    system("bundle exec rake db:test:prepare")

    app.git add: "."
    commit "Set up development and test databases"

    app.inject_into_file "spec/rails_helper.rb", after: "RSpec.configure do |config|\n" do <<-"RUBY"
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    if example.metadata[:skip_cleaning]
      example.run
    else
      DatabaseCleaner.cleaning { example.run }
    end
  end

RUBY
    end

    @database_created = true
  end

  def add_gds_sso
    setup_database

    add_gem "gds-sso", "12.1.0"
    add_gem "plek", "~> 1.12"

    app.run "bundle install"

    app.copy_file "templates/config/initializers/gds-sso.rb", "config/initializers/gds-sso.rb"
    app.copy_file "templates/spec/support/authentication_helper.rb", "spec/support/authentication_helper.rb"

    app.inject_into_file "app/controllers/application_controller.rb", after: "class ApplicationController < ActionController::Base\n" do <<-"RUBY"
  include GDS::SSO::ControllerMethods

  before_action :require_signin_permission!

RUBY
    end

    app.inject_into_file "spec/rails_helper.rb", after: %{require "spec_helper"\n} do <<-"RUBY"
require "database_cleaner"
RUBY
    end

    app.inject_into_file "spec/rails_helper.rb", after: "RSpec.configure do |config|\n" do <<-"RUBY"
  config.include AuthenticationHelper::RequestMixin, type: :request
  config.include AuthenticationHelper::ControllerMixin, type: :controller

  config.after do
    GDS::SSO.test_user = nil
  end

  [:controller, :request].each do |spec_type|
    config.before :each, type: spec_type do
      login_as_stub_user
    end
  end

RUBY
    end

    app.copy_file "templates/app/models/user.rb", "app/models/user.rb"
    app.copy_file "templates/spec/factories/user.rb", "spec/factories/user.rb"
    app.copy_file "templates/db/migrate/20160622154200_create_users.rb", "db/migrate/20160622154200_create_users.rb"

    system("bundle exec rake db:migrate")
    system("bundle exec rake db:test:prepare")
  end

  def add_test_framework
    add_test_gem "rspec-rails", "~> 3.4"
    add_test_gem "webmock", require: false
    add_test_gem "timecop"
    add_test_gem "factory_girl_rails", "4.7.0"

    app.run "bundle install"

    app.generate("rspec:install")
    app.remove_file "spec/spec_helper.rb"
    app.remove_file "spec/rails_helper.rb"
    app.copy_file "templates/spec/spec_helper.rb", "spec/spec_helper.rb"
    app.copy_file "templates/spec/rails_helper.rb", "spec/rails_helper.rb"
    app.remove_dir("test")

    commit "Add rspec-rails and useful testing tools"
  end

  def add_linter
    add_test_gem "govuk-lint"

    app.run "bundle install"

    commit "Add govuk-lint for enforcing GOV.UK styleguide"
  end

  def lock_ruby_version
    app.add_file ".ruby-version", "2.3.0\n"
    app.prepend_to_file("Gemfile") { %{ruby File.read(".ruby-version").strip\n\n} }

    commit "Lock Ruby version"
  end

  def add_readme_and_licence
    app.remove_file "README.rdoc"
    app.template "templates/README.md.erb", "README.md"
    app.template "templates/LICENCE.erb", "LICENCE"

    commit "Add README.md and LICENCE"
  end

  def add_jenkins_script
    app.template "templates/Jenkinsfile.erb", "Jenkinsfile"

    commit "Add Jenkinsfile"
  end

  def add_test_coverage_reporter
    add_test_gem "simplecov", "0.11.2", require: false
    add_test_gem "simplecov-rcov", "0.2.3", require: false

    app.run "bundle install"

    app.prepend_to_file "spec/rails_helper.rb" do <<-'RUBY'
if ENV["RCOV"]
  require "simplecov"
  require "simplecov-rcov"
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start "rails"
end
RUBY
    end

    app.inject_into_file "spec/rails_helper.rb", "export RCOV=1\n",
      before: %{if bundle exec rake ${TEST_TASK:-"default"}; then\n}

    app.append_to_file ".gitignore", "/coverage\n"

    commit "Use simplecov for code coverage reporting"
  end

  def add_health_check
    app.route %{get "/healthcheck", to: proc { [200, {}, ["OK"]] }}
    app.copy_file "templates/spec/requests/healthcheck_spec.rb", "spec/requests/healthcheck_spec.rb"

    commit "Add healthcheck endpoint"
  end

  def add_errbit
    add_gem "airbrake", github: 'alphagov/airbrake', branch: 'silence-dep-warnings-for-rails-5'
    app.run "bundle install"

    app.copy_file "templates/config/initializers/airbrake.rb", "config/initializers/airbrake.rb"

    commit "Add airbrake for errbit error reporting"
  end

  def add_debuggers
    # byebug is included in the Gemfile as a Rails convention
    add_test_gem "pry"

    app.run "bundle install"

    app.prepend_to_file "spec/spec_helper.rb" do <<-'RUBY'
  require "pry"
  require "byebug"
RUBY
    end

    commit "Add common debuggers"
  end

  def add_form_builder
    add_gem "selectize-rails", "~> 0.12"
    add_gem "generic_form_builder", "~> 0.13"

    app.run "bundle install"

    app.application do <<-'RUBY'
# Better forms
    require "admin_form_builder"
    config.action_view.default_form_builder = AdminFormBuilder
    config.action_view.field_error_proc = proc {|html_tag, _| html_tag }
RUBY
    end

    app.copy_file "templates/lib/admin_form_builder.rb", "lib/admin_form_builder.rb"

    commit "Add a form builder"
  end

  def add_frontend_development_libraries
    add_gem "sass-rails", "~> 5.0"
    add_gem "uglifier", ">= 1.3.0"
    add_gem "quiet_assets", "1.1.0"

    app.run "bundle install"

    commit "Add frontend development libraries"
  end

  def add_govuk_admin_frontend_template
    add_gem "govuk_admin_template", "~> 3.5"

    app.run "bundle install"

    commit "Add the admin frontend template"

    instructions << "Setup the admin template as per https://github.com/alphagov/govuk_admin_template#govuk-admin-template"
  end

  def add_browser_testing_framework
    add_gem "capybara", "~> 2.7"
    add_gem "poltergeist", "~> 1.9"

    app.run "bundle install"

    commit "Add a browser testing framework"

    instructions << "Please test browser interactions as per the styleguide https://github.com/alphagov/styleguides/blob/master/testing.md"
  end

  def add_gds_api_adapters
    # The version of mime-types which rest-client relies on must be below 3.0
    add_gem "mime-types", "2.99.2"
    app.run "bundle update mime-types"

    add_gem "gds-api-adapters", "~> 31.1"
    app.run "bundle install"

    commit "Add GDS API adapters"
  end

  def add_sidekiq
    add_gem "govuk_sidekiq", "~> 0.0"

    app.run "bundle install"

    commit "Add govuk_sidekiq"

    instructions << "Setup sidekiq as per https://github.com/alphagov/govuk_sidekiq"
  end

  def add_content_schema_helpers
    # The version of addressable which json-schema relies on must be ~> 2.3.7
    add_gem "addressable", "~> 2.3.7"
    app.run "bundle update addressable"

    add_gem "govuk-content-schema-test-helpers", "~> 1.4"
    app.run "bundle install"

    commit "Add GOV.UK content schema test helpers"

    instructions << "GOV.UK content schema test helpers have been added to help you integrate with the publishing API or content store"
  end

  def add_frontend_application_libraries
    add_gem "slimmer", "~> 9.1"
    add_gem "govuk_frontend_toolkit"

    app.run "bundle install"

    commit "Add frontend application libraries"

    instructions << "Hook in these templating libraries:
      https://github.com/alphagov/slimmer
      https://github.com/alphagov/govuk_frontend_toolkit"
  end

  def gem_string(name, version, require, comment)
    string = %{gem "#{name}"}
    string += %{, "#{version}"} if version
    string += ", require: false" if require == false
    string += " # #{comment}" if comment

    string
  end

  def add_gem(name, version = nil, require: nil, comment: nil)
    # This produces a cleaner Gemfile than using the `gem` helper.
    app.inject_into_file "Gemfile", "#{gem_string(name, version, require, comment)}\n",
      before: "group :development, :test do\n"
  end

  def add_test_gem(name, version = nil, require: nil, comment: nil)
    # This produces a cleaner Gemfile than using the `gem` helper.
    app.inject_into_file "Gemfile", "  #{gem_string(name, version, require, comment)}\n",
      after: "group :development, :test do\n"
  end

  def commit(message)
    app.git add: "."
    app.git commit: %{-a -m "#{message}"}
  end
end
