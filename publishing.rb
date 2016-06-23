$LOAD_PATH.unshift(File.dirname(__FILE__))
require "lib/govuk_publishing_template"

template = GovukPublishingTemplate.new(self)
template.apply
template.print_instructions
