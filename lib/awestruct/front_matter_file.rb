require 'awestruct/renderable_file'

module Awestruct
  class FrontMatterFile < RenderableFile

    attr_reader :raw_page_content
    attr_reader :front_matter

    def initialize(site, source_path, relative_source_path, options = {})
      super( site, source_path, relative_source_path, options )
      @raw_page_content = ''
      load_page
    end

    protected

    def load_page
      full_content = File.read( source_path )
      yaml_content = ''

      dash_lines = 0
      mode = :yaml

      full_content.each_line do |line|
        if ( line.strip == '---' )
          dash_lines = dash_lines +1
        end
        if ( mode == :yaml )
          yaml_content << line
        else
          @raw_page_content << line
        end
        if ( dash_lines == 2 )
          mode = :page
        end
      end

      if ( dash_lines == 0 )
        @raw_page_content = yaml_content
        yaml_content = ''
      end

      begin
        @front_matter = YAML.load( yaml_content ) || {}
        @front_matter.each do |k,v| 
          self.send( "#{k}=", v )
        end
      rescue => e
        puts "error reading #{self}: #{e}"
      end
    end
  end
end
