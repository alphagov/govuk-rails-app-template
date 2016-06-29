require_relative "govuk_rails_template"

class GovukAdminTemplate < GovukRailsTemplate
  def apply
    create_bare_rails_app
    add_gemfile
    add_json_logging
    add_test_framework
    add_gds_sso
    add_linter
    lock_ruby_version
    add_readme_and_licence
    add_jenkins_script
    add_test_coverage_reporter
    add_health_check
    add_errbit
    add_debuggers
    add_form_builder
    add_frontend_development_libraries
    add_govuk_admin_frontend_template
    add_browser_testing_framework
    add_gds_api_adapters
  end
end
