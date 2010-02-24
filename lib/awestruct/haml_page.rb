module Awestruct
  class HamlPage < Renderable
    def initialize(path, output_path, url)
      super( path, output_path, url )
      read()
    end

    def read()
      @full_content = File.read( path )
      @yaml_content = ''
      @haml_content = ''

      dash_lines = 0
      mode = :yaml

      @full_content.each_line do |line|
        if ( line.strip == '---' )
          dash_lines = dash_lines +1
        end
        if ( mode == :yaml )
          @yaml_content << line
        else
          @haml_content << line
        end
        if ( dash_lines == 2 )
          mode = :haml
        end
      end

      if ( dash_lines == 0 )
        @haml_content = @yaml_content
        @yaml_content = ''
      end

      front_matter = YAML.load( @yaml_content ) || {}
      front_matter.each do |k,v| 
        self.send( "#{k}=", v )
      end
    end

    def do_render(config, page=nil, content='')
      read
      page ||= self
      haml_engine = Haml::Engine.new( @haml_content ) 
      context = {
        :page=>page,
        :content=>content,
      }.merge(config)
      begin
        rendered = haml_engine.render( nil, context )
      rescue =>e
        puts e
        puts e.backtrace
      end
    end


  end
end
