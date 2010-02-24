
require 'haml'
require 'awestruct/front_matter_file'
require 'awestruct/hamlable'

module Awestruct
  class HamlFile < FrontMatterFile

    include Hamlable

    def initialize(site, source_path)
      super(site, source_path)
    end

    def output_filename
      File.basename( source_path, '.haml' )
    end

    def render(context)
      rendered = ''
      begin
        haml_engine = Haml::Engine.new( raw_page_content )
        rendered = haml_engine.render( context )
      rescue => e
        puts e
        puts e.backtrace
      end
      rendered
    end

  end
end
