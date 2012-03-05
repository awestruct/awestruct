require 'org-ruby'

module Awestruct
  module Orgmodeable

    def render(context)
      Orgmode::Parser.new(raw_page_content).to_html
    end

    def output_extension
      'html'
    end

  end
end
