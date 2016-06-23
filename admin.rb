$LOAD_PATH.unshift(File.dirname(__FILE__))
require "lib/govuk_admin_template"

template = GovukAdminTemplate.new(self)
template.apply
template.print_instructions
