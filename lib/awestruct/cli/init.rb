require 'awestruct/cli/manifest'
require 'awestruct/cli/options'
require 'sass'
require 'sass/plugin'

module Awestruct
  module CLI
    class Init

      def self.framework_path(path, framework = nil)
        File.join [File.dirname(__FILE__), '..', 'frameworks', framework, path].compact
      end

      BASE_MANIFEST = Manifest.new {
        mkdir('_config')
        mkdir('_layouts')
        mkdir('_ext')
        copy_file('_ext/pipeline.rb', Init.framework_path('base_pipeline.rb'))
        copy_file('.awestruct_ignore', Init.framework_path('base_awestruct_ignore'))
        copy_file('Rakefile', Init.framework_path('base_Rakefile'))
        copy_file('Gemfile', Init.framework_path('base_Gemfile'))
        mkdir('stylesheets')
      }

      def initialize(dir = Dir.pwd, framework = 'compass', scaffold = true)
        @dir = dir
        @framework = framework
        @scaffold = scaffold
      end

      def run()
        manifest = Manifest.new(BASE_MANIFEST)
        scaffold_name = @framework
        lib = nil
        case @framework
          when 'compass'
            scaffold_name = 'blueprint'
          when 'bootstrap'
            lib = 'bootstrap-sass'
          when 'foundation'
            lib = 'zurb-foundation'
          when '960'
            lib = 'ninesixty'
        end
        require lib unless lib.nil?
        manifest.install_compass(@framework)
        if (@scaffold)
          manifest.copy_file('_config/site.yml', framework_path('base_site.yml'), :overwrite => true)
          manifest.copy_file('_layouts/base.html.haml', framework_path('base_layout.html.haml', scaffold_name))
          base_index = framework_path('base_index.html.haml', scaffold_name)
          if File.file? base_index
            manifest.copy_file('index.html.haml', base_index)
          else
            manifest.copy_file('index.html.haml', framework_path('base_index.html.haml'))
          end

          humans_txt = framework_path('humans.txt')
          if File.file? humans_txt
            manifest.copy_file('humans.txt', humans_txt, :overwrite => true)
          end

          manifest.touch_file('_config/site.yml')
          manifest.add_requires('_ext/pipeline.rb', [lib]) unless lib.nil?
          if scaffold_name == 'foundation'
            manifest.remove_file('index.html')
            manifest.remove_file('MIT-LICENSE.txt')
          end
        end
        manifest.perform(@dir)
      end

      def framework_path(path, framework = nil)
        Init.framework_path path, framework
      end

    end
  end
end
