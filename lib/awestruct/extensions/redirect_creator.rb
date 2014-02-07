# Awestruct extension creating html pages with redirect directives.
#
# Configuration via _config/redirects.yml or by passing a list of yaml files in the pipeline constructor,
# e.g Awestruct::Extensions::RedirectCreator.new "foo", "bar"
#
# The extension also needs a template file containing the HTML for the redirect page. The path to the 
# template can be configured in site.yml using the property 'redirect_creator_template'. If the property
# is not set 'redirects.template' in _config is assumed. 
#
# %{url} should be used within the template to insert the redirect target.
require 'awestruct/handlers/base_handler'

module Awestruct
  module Extensions
    class RedirectCreator
      Default_Redirect_Config = "redirects"

      def initialize(*args)
        @redirect_configs = Array.new
        @redirect_configs.push(*args)
        if @redirect_configs.index(Default_Redirect_Config) == nil
          @redirect_configs.push(Default_Redirect_Config)
        end
      end

      def execute(site)
        @redirect_configs.each { |config|
          if !site[config].nil?
            site[config].each do |requested_url, target_url|
              redirect_page = Page.new(site, Handlers::RedirectCreationHandler.new( site, requested_url, target_url ))
              # make sure indexifier is ignoring redirect pages
              redirect_page.inhibit_indexifier = true
              site.pages << redirect_page
            end
          else
            abort("Redirect config _config/#{config}.yml does not exist")
          end

        }
      end
    end
  end

  module Handlers
    class RedirectCreationHandler < BaseHandler

      Template_Config_Property = "redirect_creator_template"
      Default_Redirect_Template = "redirects.template"
      def initialize(site, requested_url, target_url)
        super( site )
        @requested_url = requested_url
        @target_url = target_url
        @creation_time = Time.new
        template_file = site[Template_Config_Property]
        if template_file.nil?
          template_file = File.join(File.dirname(__FILE__), "..", "_config", Default_Redirect_Template)
        end
        @template = load_template template_file
      end

      def simple_name
        File.basename( @requested_url, ".*" )
      end

      def output_filename
        simple_name + output_extension
      end

      def output_extension
        '.html'
      end

      def output_path
        if( File.extname( @requested_url ).empty?)
          File.join( File.dirname(@requested_url), simple_name, "index.html" )
        else
          File.join( File.dirname(@requested_url), output_filename )
        end
      end

      def content_syntax
        :text
      end

      def input_mtime(page)
        @creation_time
      end

      def rendered_content(context, with_layouts=true)
        @template
      end

      private
      def load_template(template_file)
        if !File.exist?(template_file)
          abort("RedirectCreator is configured in pipeline, but redirect template (#{template_file}) does not exist")
        end
        file = File.open(template_file, "rb")
        content = file.read
        file.close
        content % {url: @target_url}
      end
    end
  end
end
