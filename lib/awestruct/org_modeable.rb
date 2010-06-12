
require 'org-ruby'

module Awestruct
  module OrgModeable

    def render(context)
      Orgmode::Parser.new(raw_page_content).to_html
    end

    def output_extension
      'html'
    end

  end
end
