require 'open-uri'

module Awestruct
  module Extensions
    module RemotePartial

      def remotePartial(url)

        page = open(url)
        return nil if !page
        page.read

      end

    end
  end
end
