require_relative "govuk_rails_template"

class GovukFrontendTemplate < GovukRailsTemplate
  def apply
    create_bare_rails_app
    add_gemfile
    add_json_logging
    add_test_framework
    add_linter
    lock_ruby_version
    add_readme_and_licence
    add_jenkins_script
    add_test_coverage_reporter
    add_health_check
    add_govuk_app_config
    add_debuggers
    add_content_schema_helpers
    add_frontend_development_libraries
    add_browser_testing_framework
    add_gds_api_adapters
    add_frontend_application_libraries
  end
end
