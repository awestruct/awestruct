
require 'awestruct/handlers/base_handler'

require 'compass'
require 'ninesixty'
require 'bootstrap-sass'

module Awestruct
  module Handlers
    class BaseSassHandler < BaseHandler

      attr_reader :syntax

      def initialize(site, delegate, syntax)
        super( site, delegate )
        @syntax = syntax
      end

      def simple_name
        File.basename( relative_source_path, ".#{syntax}" )
      end

      def output_filename
        simple_name + '.css'
      end

      def rendered_content(context, with_layouts=true)
        sass_opts = Compass.sass_engine_options
        sass_opts[:load_paths] ||= []
        Compass::Frameworks::ALL.each do |framework|
          sass_opts[:load_paths] << framework.stylesheets_directory
        end
        sass_opts[:load_paths] << File.dirname( context.page.source_path )
        sass_opts[:syntax] = syntax
        sass_opts[:custom] = site
        sass_engine = Sass::Engine.new( raw_content, sass_opts )
        sass_engine.render
      end

    end
  end
end
