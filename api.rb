$LOAD_PATH.unshift(File.dirname(__FILE__))
require "lib/govuk_api_template"

template = GovukAPITemplate.new(self)
template.apply
template.print_instructions
