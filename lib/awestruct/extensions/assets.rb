require 'awestruct/extensions/relative'

module Awestruct
  module Extensions
    module Assets

      include Awestruct::Extensions::Relative

      def asset(href)
        if site.assets_url
          File.join(site.assets_url, href)
        else
	  relative(File.join("/#{site.assets_path || 'assets'}", href))
        end
      end

      class Extension

	def execute(site)
	  site.pages.each{ |p| p.extend Extension }
        end

	module Extension

	  include Awestruct::Extensions::Relative

	  def assets_url
	    path = File.join("/#{site.assets_path || 'assets'}", File.join(File.dirname(output_path), File.basename(output_path, '.*')))
	    relative(path, self)
          end
        end
      end
    end
  end
end
