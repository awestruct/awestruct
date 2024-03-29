require 'awestruct/handlers/base_handler'
require 'awestruct/util/yaml_load'

module Awestruct
  module Handlers
    class YamlHandler < BaseHandler

      def initialize(site, delegate)
        super
      end

      def front_matter
        return @front_matter if @front_matter
        @front_matter = Awestruct.yaml_load( delegate.raw_content )
        @front_matter
      end

      def raw_content
        nil
      end

    end
  end
end
