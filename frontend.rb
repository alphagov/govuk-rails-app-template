$LOAD_PATH.unshift(File.dirname(__FILE__))
require "lib/govuk_frontend_template"

template = GovukFrontendTemplate.new(self)
template.apply
template.print_instructions
