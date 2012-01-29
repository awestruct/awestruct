require 'awestruct/extensions/relative'
require 'pathname'

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

      class Transformer
        # FIXME this is not DRY at all
        def relative(page, href)
          Pathname.new(href).relative_path_from(Pathname.new(File.dirname(page.output_path))).to_s
        end
        def asset(site, page, href)
          if site.assets_url
            File.join(site.assets_url, href)
          else
            relative(page, File.join("/#{site.assets_path||'assets'}", href))
          end
        end
        def transform(site, page, input)
          if page.output_path =~ /\.html/
            input.gsub('asset://', asset(site, page, "#{File.basename(File.basename(page.source_path, ".md"))}") + "/")
          else
            input
          end
        end
      end

    end
  end
end
