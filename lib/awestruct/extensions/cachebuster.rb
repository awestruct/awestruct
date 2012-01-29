module Awestruct
  module Extensions
    module Cachebuster
      def timestamp
        (Time.now.to_i / 1000).to_i
      end
      def cache(href)
        "#{href}?#{site.cachebuster||timestamp}"
      end
    end
  end
end