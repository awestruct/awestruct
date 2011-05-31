require 'sass'

require 'compass'

module Sass::Script::Functions
  def site(path)
    site = options[:custom]
    Sass::Script::String.new(site.send(path.value.to_s).to_s)
  end
end

module Awestruct
  module Sassable

    def render(context)
      sass_opts = Compass.sass_engine_options
      sass_opts[:load_paths] ||= []
      Compass::Frameworks::ALL.each do |framework|
        sass_opts[:load_paths] << framework.stylesheets_directory
      end
      sass_opts[:load_paths] << File.dirname( self.source_path )
      sass_opts[:syntax] = syntax()
      sass_opts[:custom] = site
      sass_engine = Sass::Engine.new( raw_page_content, sass_opts )
      sass_engine.render
    end

    def output_extension
      'css'
    end

  end
end
