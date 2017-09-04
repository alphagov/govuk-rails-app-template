require_relative "govuk_rails_template"

class GovukAPITemplate < GovukRailsTemplate
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
    add_govuk_app_config
    add_debuggers
  end
end
