module Awestruct
  module Extensions
    module Cachebuster

      def cache(href)
	"#{href}?#{cachebuster}"
      end

      def cachebuster(p=page)
	((site.timestamp || p.input_mtime || Time.now.to_i) / 1000).to_i.to_s
      end

    end
  end
end