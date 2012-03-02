module Haml::Filters::AsciiDoc
  include Awestruct::AsciiDocable # must come first
  include Haml::Filters::Base

  def render_with_options(text, options)
    _render(text, options[:relative_source_path])
  end
end
