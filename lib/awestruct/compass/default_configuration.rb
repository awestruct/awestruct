require 'compass/configuration/defaults'

module Awestruct
  module Compass
    class DefaultConfiguration < ::Compass::Configuration::Data

      attr_reader :site

      def initialize site
        @site = site
      end

      def project_type
        :stand_alone
      end

      def environment
        site.profile
      end

      def project_path
        site.config.dir
      end

      def sass_dir
        File.join site.config.dir, 'stylesheets'
      end

      def http_path
        site.base_url
      end

      def css_dir
        site.css_dir
      end

      def javascripts_dir
        File.join site.config.dir, 'javascripts'
      end

      def http_javascripts_dir
        File.join http_path, 'javascripts' 
      end

      def http_stylesheets_dir
        File.join http_path, 'stylesheets'
      end

      def images_dir
        File.join site.config.dir, 'images'
      end

      def generated_images_dir
        File.join site.output_path, 'images'
      end

      def http_generated_images_dir
        File.join http_path, 'images'
      end

      def sprite_load_path
        [images_path]
      end

      def images_path
        File.join project_path, 'images'
      end

      def http_images_dir
        File.join http_path, 'images'
      end

      def fonts_dir
        File.join site.config.dir, 'fonts'
      end

      def http_fonts_dir
        File.join http_path, 'fonts'
      end

      def line_comments
        site.key?(:compass_line_comments) ? !!site.compass_line_comments : !site.profile.eql?('production') 
      end

      def output_style
        site.key?(:compass_output_style) ? site.compass_output_style.to_sym : site.profile.eql?('production') ? :compressed : :expanded 
      end

      def relative_assets
        false
      end

      def cache_dir
        File.join site.config.dir, '.sass-cache'
      end

      def inherit_from! data
        return
      end
    end 
  end
end

