require_relative "govuk_admin_template"

class GovukPublishingTemplate < GovukAdminTemplate
  def apply
    super

    add_sidekiq
    add_content_schema_helpers
  end
end
