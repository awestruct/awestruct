require 'awestruct/util/inflector'
require 'awestruct/util/exception_helper'
require 'awestruct/util/default_inflections'

require 'awestruct/config'
require 'awestruct/compass/default_configuration'
require 'awestruct/site'
require 'awestruct/pipeline'
require 'awestruct/page'
require 'awestruct/page_loader'

require 'awestruct/extensions/pipeline'

require 'fileutils'
require 'set'
require 'date'

require 'compass'
require 'parallel'

class OpenStruct
  def inspect
    "OpenStruct{...}"
  end
end

module Awestruct

  class Engine

    attr_reader :site
    attr_reader :pipeline
    attr_reader :config

    def self.instance
      @instance
    end

    def self.instance=(engine)
      @instance = engine
    end

    def initialize(config=Awestruct::Config.new)
      Engine.instance = self
      @site = Site.new( self, config)
      @pipeline = Pipeline.new
      @site_page_loader = PageLoader.new( @site )
      @layout_page_loader = PageLoader.new( @site, :layouts )
      @config = config
    end

    def config
      site.config
    end

    def run(profile, base_url, default_base_url, force=false)
      $LOG.debug 'adjust_load_path' if $LOG.debug?
      adjust_load_path
      $LOG.debug 'load_default_site_yaml' if $LOG.debug?
      load_default_site_yaml( profile )
      $LOG.debug 'load_user_site_yaml -- profile' if $LOG.debug?
      load_user_site_yaml( profile )
      $LOG.debug 'set_base_url' if $LOG.debug?
      set_base_url( base_url, default_base_url )
      $LOG.debug 'load_yamls' if $LOG.debug?
      load_yamls
      $LOG.debug 'load_pipeline' if $LOG.debug?
      load_pipeline
      $LOG.debug 'load_pages' if $LOG.debug?
      load_pages
      $LOG.debug 'execute_pipeline' if $LOG.debug?
      $LOG.info 'Excecuting pipeline...' if $LOG.info?
      execute_pipeline
      $LOG.debug 'configure_compass' if $LOG.debug?
      configure_compass
      $LOG.debug 'set_urls' if $LOG.debug?
      set_urls( site.pages )
      $LOG.debug 'build_page_index' if $LOG.debug?
      build_page_index
      $LOG.debug 'generate_output' if $LOG.debug?
      $LOG.info 'Generating pages...' if $LOG.info?
      generate_output
      return 0
    end

    def build_page_index
      site.pages_by_relative_source_path = {}
      site.pages.each do |p|
        # Add the layout to the set of dependencies
        p.dependencies.add_dependency(site.layouts.find_matching(p.layout, p.output_extension))
        if ( p.relative_source_path )
          site.pages_by_relative_source_path[ p.relative_source_path ] = p
        end
      end
      site.layouts.each do |p|
        # Add the layout to the set of dependencies
        p.dependencies.add_dependency(site.layouts.find_matching(p.layout, p.output_extension))

        if ( p.relative_source_path )
          site.pages_by_relative_source_path[ p.relative_source_path ] = p
        end
      end
    end

    def set_base_url(base_url, default_base_url)
      if ( base_url )
        site.base_url = base_url
      end

      if ( site.base_url.nil? )
        site.base_url = default_base_url
      end

      if ( site.base_url )
        if ( site.base_url =~ /^(.*)\/$/ )
          site.base_url = $1
        end
      end

    end

    def load_default_site_yaml(profile = nil)
      default_site_yaml_path = File.join( File.dirname( __FILE__ ), 'config', 'default-site.yml' )
      load_site_yaml( default_site_yaml_path, profile )
    end

    def load_user_site_yaml(profile = nil)
      site_yaml_path = File.join( site.config.config_dir, 'site.yml' )
      load_site_yaml( site_yaml_path, profile )
    end

    def load_yamls
      Dir[ File.join( site.config.config_dir, '*.yml' ) ].each do |yaml_path|
        load_yaml( yaml_path ) unless ( File.basename( yaml_path ) == 'site.yml' )
      end
    end

    def load_site_yaml(yaml_path, profile = nil)
      if ( File.exist?( yaml_path ) )
        begin
          data = YAML.load( File.read( yaml_path, :encoding => 'bom|utf-8' ) )
          if ( profile )
            # JP: Interpolation now turned off by default, turn it per page if needed
            site.interpolate = false
            profile_data = {}
            data.each do |k,v|
              if ( ( k == 'profiles' ) && ( ! profile.nil? ) )
                profile_data = ( v[profile] || {} )
              else
                site.send( "#{k}=", merge_data( site.send( "#{k}" ), v ) )
              end
            end if data
            site.profile = profile
            profile_data.each do |k,v|
              site.send( "#{k}=", merge_data( site.send( "#{k}" ), v ) )
            end
          else
            data.each do |k,v|
              site.send( "#{k}=", v )
            end if data
          end
        rescue Exception => e
          ExceptionHelper.log_building_error e, yaml_path
          ExceptionHelper.mark_failed
        end
      end
    end

    def load_yaml(yaml_path)
      begin
        data = YAML.load( File.read( yaml_path ) )
      rescue Exception => e
        ExceptionHelper.log_building_error e, yaml_path
        ExceptionHelper.mark_failed
      end
      name = File.basename( yaml_path, '.yml' )
      site.send( "#{name}=", massage_yaml( data ) )
    end

    def merge_data(existing, new)
      if existing.kind_of? Hash
        result = existing.inject({}) do |merged, (k,v)|
          if new.has_key? k
            if v.kind_of? Hash
              merged[k] = merge_data(v, new.delete(k))
            else
              merged[k] = new.delete(k)
            end
          else
            merged[k] = v
          end
          merged
        end
        result.merge new
      else
        new
      end
    end

    def massage_yaml(obj)
      result = obj
      case ( obj )
        when Hash
          result = {}
          obj.each do |k,v|
            result[k] = massage_yaml(v)
          end
          result = AStruct.new( result ).cascade_for_nils!
        when Array
          result = []
          obj.each do |v|
            result << massage_yaml(v)
          end
      end
      result
    end

    def adjust_load_path
      ext_dir = File.join( site.config.extension_dir )
      if ( $LOAD_PATH.index( ext_dir ).nil? )
        $LOAD_PATH << ext_dir
      end
    end

    def set_urls(pages)
      pages.each do |page|
        $LOG.debug "relative_source_path #{page.relative_source_path}" if $LOG.debug?
        page_path = page.output_path
        if ( page_path =~ /^\// )
          page.url = page_path
        else
          page.url = "/#{page_path}"
        end
        if ( page.url =~ /^(.*\/)index.html$/ )
          page.url = $1
        end
      end
    end

    def load_pipeline
      ext_dir = File.join( site.config.extension_dir )
      pipeline_file = File.join( ext_dir, 'pipeline.rb' )
      if ( File.exists?( pipeline_file ) )
        p = eval(File.read( pipeline_file ), nil, pipeline_file, 1)
        p.extensions.each do |e|
          pipeline.extension( e )
        end
        p.helpers.each do |h|
          pipeline.helper( h )
        end
        p.transformers.each do |t|
          pipeline.transformer( t )
        end
      end
    end

    def execute_pipeline
      FileUtils.mkdir_p( site.config.output_dir )
      FileUtils.mkdir_p( site.config.tmp_dir )
      pipeline.execute( site )
    end

    def configure_compass 
      site.images_dir      = File.join( site.config.dir, 'images' )
      site.fonts_dir       = File.join( site.config.dir, 'fonts' )
      site.stylesheets_dir = File.join( site.config.dir, 'stylesheets' )
      site.javascripts_dir = File.join( site.config.dir, 'javascripts' )

      default_config = Awestruct::Compass::DefaultConfiguration.new(site)
      compass_config_file = File.join(site.config.config_dir, 'compass.rb')
      if (File.exists? compass_config_file)
        default_config.inherit_from! ::Compass::Configuration::FileData.new_from_file(compass_config_file) 
      end 

      ::Compass.add_configuration default_config

      # TODO: Should we add an on_stylesheet_error block?  
    end

    def load_pages
      $LOG.debug "layout_page_loader.load_all :post" if $LOG.debug?
      @layout_page_loader.load_all( :post )
      $LOG.debug "site_page_loader.load_all :inline" if $LOG.debug?
      @site_page_loader.load_all( :inline )
    end

    def generate_output
      FileUtils.mkdir_p( site.config.output_dir )
      Parallel.each(@site.pages, :in_processes => Parallel.processor_count) do |page|
        generated_path = File.join( site.config.output_dir, page.output_path )
        if ( page.stale_output?( generated_path ) )
          generate_page( page, generated_path )
        else
          generate_page( page, generated_path, false )
        end
      end
    end

    def generate_page(page, generated_path, produce_output=true)
      if ( produce_output )
        $LOG.debug "Generating: #{generated_path}" if $LOG.debug? && config.verbose
        FileUtils.mkdir_p( File.dirname( generated_path ) )

        c = page.rendered_content
        c = site.engine.pipeline.apply_transformers( site, page, c )

        File.open( generated_path, 'wb' ) do |file|
          file << c
        end
      elsif ( site.config.track_dependencies )
        if page.dependencies.load!
          $LOG.debug "Cached:     #{generated_path}" if $LOG.debug?
        else
          $LOG.debug "Analyzing:  #{generated_path}" if $LOG.debug?
          page.rendered_content
        end
      end
    end

    # path - relative to output dir
    def page_by_source_path(path)
      if (path.include? '_layout')
        site.layouts.find { |p| p.source_path.to_s == path }
      elsif (path.include? '_partial')
        site.partials.find { |p| p.source_path.to_s == path }
      else
        site.pages.find { |p| p.source_path.to_s == path }
      end
    end

    def generate_page_and_dependencies(page)

      if page.nil?
        return
      end

      if !page.output_path.nil? && !page.is_partial? && !page.__is_layout
        generate_page_internal(page)
      end

      regen_pages = Set.new [ page ] 
      regen_pages.merge page.dependencies.dependents

      # doing this in case someone has used key dependencies
      page.dependencies.key_dependents.each do |kd|
        if kd.is_a? Page
          regen_pages << kd
        end    
      end

      temp_set = Set.new
      regen_pages.each do |p|
        temp_set.merge find_transitive_dependents(page) 
      end

      regen_pages.merge temp_set

      $LOG.debug "Starting regeneration of content dependent pages:" if regen_pages.size > 0 && $LOG.debug?

      regen_pages.each do |p|
        $LOG.info "Regenerating page #{p.output_path}" if $LOG.info?
        generate_page_internal(p)
      end

      regen_pages
    end

    def run_auto_for_non_page(file)
      if File.extname(file) == '.rb'
        load file
      end
      @pipeline = Pipeline.new
      load_yamls
      load_pipeline
      execute_pipeline
      site.pages.each do |p|
        generate_page_internal(p)
      end
      site.pages
    end

    def generate_page_internal(p)
      unless ( p.output_path.nil? || p.__is_layout || !p.stale_output?(p.output_path) )
        generated_path = File.join( site.config.output_dir, p.output_path )
        generate_page( p, generated_path )
      end
    end

    ####
    ## compat with awestruct 0.2.x
    ####

    def load_page(path, options={})
      page = @site_page_loader.load_page( path )
      if ( options[:relative_path] )
        fixed_relative_path = ( options[:relative_path].nil? ? nil : File.join( '', options[:relative_path] ) )
        page.relative_path = fixed_relative_path
      end
      page
    end

    def load_site_page(relative_path)
      load_page( File.join( site.config.dir, relative_path ) )
    end

    def find_and_load_site_page(simple_path)
      path_glob = File.join( site.config.input_dir, simple_path + '.*' )
      candidates = Dir[ path_glob ]
      return nil if candidates.empty?
      throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
      dir_pathname = Pathname.new( site.config.dir )
      path_name = Pathname.new( candidates[0] )
      path_name.relative_path_from( dir_pathname ).to_s
      load_page( candidates[0] )
    end

    def create_context(page, content='')
      page.create_context( content )
    end

    def find_transitive_dependents(page)
      deps = Set.new 
      deps << page
      if page.dependencies.dependents.size > 0
        page.dependencies.dependents.to_a.inject(deps) do |set, p| 
          set.merge find_transitive_dependents(p)
          set
        end
      end
      deps
    end

  end

end
