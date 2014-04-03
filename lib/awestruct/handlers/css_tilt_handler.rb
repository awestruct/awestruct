require 'awestruct/handlers/base_tilt_handler'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/front_matter_handler'
require 'awestruct/handlers/layout_handler'

require 'compass'

module Awestruct
  module Handlers
    class CssTiltHandler < BaseTiltHandler

      CHAIN = Awestruct::HandlerChain.new(/\.(sass|scss|less)$/,
        Awestruct::Handlers::FileHandler,
        Awestruct::Handlers::CssTiltHandler
      )

      def initialize(site, delegate)
        super( site, delegate )
      end

      ##
      # Sass Engine requires dynamically generated options.
      ##
      def options
        opts = super

        # Sass / Scss
        opts[:load_paths] ||= []
        ::Compass::Frameworks::ALL.each do |framework|
          opts[:load_paths] << framework.stylesheets_directory
        end
        opts[:load_paths] << File.join(site.config.dir.to_s, File.dirname(relative_source_path) ) unless relative_source_path.nil?

        # Less use Paths instead of load_paths
        opts[:paths] = opts[:load_paths]

        return opts
      end

    end
  end
end
