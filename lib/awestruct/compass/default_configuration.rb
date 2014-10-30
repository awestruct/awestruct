require 'compass'

module Awestruct
  module Compass
    class DefaultConfiguration < ::Compass::Configuration::Data

      attr_reader :site

      def initialize site
        @site = site
      end

      def default_project_type
        :stand_alone
      end

      def default_environment
        site.profile
      end

      def default_project_path
        site.config.dir
      end

      def default_sass_dir
        File.join site.config.dir, 'stylesheets'
      end

      def default_http_path
        site.base_url
      end

      def default_css_dir
        File.join site.output_dir, 'stylesheets'
      end

      def default_javascripts_dir
        File.join site.config.dir, 'javascripts'
      end

      def default_http_javascripts_dir
        File.join http_path, 'javascripts' 
      end

      def default_http_stylesheets_dir
        File.join http_path, 'stylesheets'
      end

      def default_images_dir
        File.join site.config.dir, 'images'
      end

      def default_generated_images_dir
        File.join site.output_dir, 'images'
      end

      def default_http_generated_images_dir
        File.join http_path, 'images'
      end

      def default_sprite_load_path
        [images_path]
      end

      def default_images_path
        File.join project_path, 'images'
      end

      def default_http_images_dir
        File.join http_path, 'images'
      end

      def default_fonts_dir
        File.join site.config.dir, 'fonts'
      end

      def default_http_fonts_dir
        File.join http_path, 'fonts'
      end

      def line_comments
        if self.inherited_data && self.inherited_data.is_a?(::Compass::Configuration::FileData)
          return self.inherited_data.line_comments
        end
        if site.profile.eql? 'production'
          return false
        else
          if site.key? :compass_line_comments
            return site.compass_line_comments 
          end
          if site.key?(:scss) && site.scss.key?(:line_comments)
            return site.scss.line_comments
          end
          if site.key?(:sass) && site.sass.key?(:line_comments)
            return site.sass.line_comments
          end
          true
        end
      end

      def output_style
        if self.inherited_data && self.inherited_data.is_a?(::Compass::Configuration::FileData)
          return self.inherited_data.output_style
        end
        if site.profile.eql? 'production'
          return :compressed
        else
          if site.key? :compass_output_style
            return site.compass_output_style
          end
          if (site.key? :scss) && (site.scss.key? :style)
            return site.scss.style
          end
          if (site.key? :sass) && (site.sass.key? :style)
            return site.sass.style
          end
        end
        :expanded
      end

      def default_relative_assets
        false
      end

      def default_cache_dir
        File.join site.config.dir, '.sass-cache'
      end
    end 
  end
end

