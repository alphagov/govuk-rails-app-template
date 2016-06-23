class AdminFormBuilder < GenericFormBuilder
  FIELD_WIDTHS = {
    text_area: 8
  }.freeze

  STANDARD_FIELD_WIDTH = 6

  STANDARD_FIELDS.each do |method|
    method = method.to_sym

    define_method(method) do |field, *args|
      options, *args = args
      options ||= {}

      options[:wrapper_html_options] = {class: "form-group"}.merge(options[:wrapper_html_options] || {})
      options[:class] = Array(options[:class]) + ["form-control", "input-md-#{field_width(method)}"]

      super(field, options, *args)
    end
  end

  def buttons(options)
    super(options.merge(
      button_class: %w( btn btn-success ),
      cancel_class: %w( btn btn-link )
    ))
  end

  def select(field, collection, options = {}, html_options = {})
    options[:wrapper_html_options] = {class: "form-group"}.merge(options[:wrapper_html_options] || {})
    html_options[:class] = Array(html_options[:class]) + ["form-control", "input-md-#{field_width(:select)}"]

    super(field, collection, options, html_options)
  end

private

  def field_width(field)
    FIELD_WIDTHS[field] || STANDARD_FIELD_WIDTH
  end
end
