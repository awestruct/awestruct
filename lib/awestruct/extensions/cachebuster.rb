module Awestruct
  module Extensions
    module Cachebuster

      def cache(href)
	"#{href}?#{cachebuster}"
      end

      class Extension

	def execute(site)
	  site.pages.each{ |p| p.extend Extension }
	end

	module Extension
	  def cachebuster
	    ((site.timestamp || page.input_mtime || Time.now.to_i) / 1000).to_i.to_s
	  end
	end
      end
    end
  end
end