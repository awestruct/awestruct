require 'awestruct/extensions/relative'

module Awestruct
  module Extensions
    module Assets
      def asset(href)
        if site.assets_url
          File.join(site.assets_url, href)
        else
          relative(File.join("/#{site.assets_path||'assets'}", href))
        end
      end
    end
  end
end

# class ResourceLinks
# 
#   def transform(site, page, input)
#     if page.output_path =~ /\.html/
#       input.gsub('resource://', "#{site.resources_url}/#{File.basename(File.basename(page.source_path, ".md"))}/")
#     else
#       input
#     end
#   end
# 
# end
