require 'awestruct/util/inflector'
require 'awestruct/util/exception_helper'
require 'awestruct/util/default_inflections'

require 'awestruct/config'
require 'awestruct/site'
require 'awestruct/pipeline'
require 'awestruct/page'
require 'awestruct/page_loader'

require 'awestruct/extensions/pipeline'

require 'fileutils'
require 'set'
require 'date'
require 'erb'

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

    def run(profile, base_url, default_base_url, force=false, generate=true)
      start_time = DateTime.now
      $LOG.verbose 'adjust_load_path' if config.verbose
      adjust_load_path
      $LOG.trace "Total time in adjust_load_path: #{DateTime.now.to_time - start_time.to_time} seconds"

      $LOG.verbose 'load_default_site_yaml' if config.verbose
      start_time = DateTime.now
      load_default_site_yaml( profile )
      $LOG.trace "Total time in load_default_site_yaml #{DateTime.now.to_time - start_time.to_time} seconds"

      $LOG.verbose 'load_user_site_yaml -- profile' if config.verbose
      start_time = DateTime.now
      load_user_site_yaml( profile )
      $LOG.trace "Total time in load_user_site_yaml #{DateTime.now.to_time - start_time.to_time} seconds"

      $LOG.verbose 'set_base_url' if config.verbose
      start_time = DateTime.now
      set_base_url( base_url, default_base_url )
      $LOG.trace "Total time in set_base_url #{DateTime.now.to_time - start_time.to_time} seconds"

      $LOG.verbose 'load_yamls' if config.verbose
      start_time = DateTime.now
      load_yamls
      $LOG.trace "Total time in load_yamls #{DateTime.now.to_time - start_time.to_time} seconds"

      $LOG.verbose 'load_pipeline' if config.verbose
      start_time = DateTime.now
      load_pipeline
      $LOG.trace "Total time in load_pipeline #{DateTime.now.to_time - start_time.to_time} seconds"

      $LOG.verbose 'load_pages' if config.verbose
      start_time = DateTime.now
      load_pages
      $LOG.trace "Total time in load_pages #{DateTime.now.to_time - start_time.to_time} seconds"

      $LOG.verbose 'execute_pipeline' if config.verbose
      $LOG.info 'Excecuting pipeline...'
      start_time = DateTime.now
      execute_pipeline(false)
      $LOG.trace "Total time in execute_pipeline #{DateTime.now.to_time - start_time.to_time} seconds"

      begin
        if defined?(::Compass)
          $LOG.verbose 'configure_compass' if config.verbose
          start_time = DateTime.now
          configure_compass
          $LOG.trace "Total time in configure_compass #{DateTime.now.to_time - start_time.to_time} seconds"
        end
      rescue LoadError
        # doesn't matter if we can't load it
      end
      $LOG.verbose 'set_urls' if config.verbose
      start_time = DateTime.now
      set_urls( site.pages )
      $LOG.trace "Total time in set_urls #{DateTime.now.to_time - start_time.to_time} seconds"

      $LOG.verbose 'build_page_index' if config.verbose
      start_time = DateTime.now
      build_page_index
      $LOG.trace "Total time in build_page_index #{DateTime.now.to_time - start_time.to_time} seconds"

      if generate
        $LOG.debug 'generate_output' if config.debug
        $LOG.info 'Generating pages...'
        start_time = DateTime.now
        generate_output
        $LOG.trace "Total time in generate_output #{DateTime.now.to_time - start_time.to_time} seconds"
      end
      Awestruct::ExceptionHelper::EXITCODES[:success]
    end

    def build_page_index
      site.pages_by_relative_source_path = {}
      site.pages_by_output_path = {}
      site.pages.each do |p|
        # Add the layout to the set of dependencies
        p.dependencies.add_dependency(site.layouts.find_matching(p.layout, p.output_extension))
        if p.relative_source_path
          site.pages_by_relative_source_path[ p.relative_source_path ] = p
        end
        site.pages_by_output_path[ p.output_path ] = p
      end
      site.layouts.each do |p|
        # Add the layout to the set of dependencies
        p.dependencies.add_dependency(site.layouts.find_matching(p.layout, p.output_extension))

        if p.relative_source_path
          site.pages_by_relative_source_path[ p.relative_source_path ] = p
        end
      end
    end

    def set_base_url(base_url, default_base_url)
      if base_url
        site.base_url = base_url
      end

      if site.base_url.nil?
        site.base_url = default_base_url
      end

      if site.base_url
        if site.base_url =~ /^(.*)\/$/
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
      if File.exist?(yaml_path)
        begin
          data = YAML.load( ERB.new(File.read( yaml_path, :encoding => 'bom|utf-8' )).result )
          if profile
            # JP: Interpolation now turned off by default, turn it per page if needed
            site.interpolate = false
            profile_data = {}
            data.each do |k,v|
              if (k == 'profiles') && (!profile.nil?)
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
        data = YAML.load( ERB.new(File.read( yaml_path )).result )
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
      if $LOAD_PATH.index(ext_dir).nil?
        $LOAD_PATH << ext_dir
      end
    end

    def set_urls(pages)
      pages.each do |page|
        $LOG.debug "relative_source_path #{page.relative_source_path}" if config.debug
        page_path = page.output_path
        if page_path =~ /^\//
          page.url = page_path
        else
          page.url = "/#{page_path}"
        end
        if page.url =~ /^(.*\/)index.html$/
          page.url = $1
        end
      end
    end

    def load_pipeline
      ext_dir = File.join( site.config.extension_dir )
      pipeline_file = File.join( ext_dir, 'pipeline.rb' )
      if File.exists?(pipeline_file)
        p = eval(File.read( pipeline_file ), nil, pipeline_file, 1)
        p.before_all_extensions.each do |e|
          pipeline.add_before_extension( e )
        end
        p.extensions.each do |e|
          pipeline.extension( e )
        end
        p.after_all_extensions.each do |e|
          pipeline.add_after_extension( e )
        end
        p.helpers.each do |h|
          pipeline.helper( h )
        end
        p.transformers.each do |t|
          pipeline.transformer( t )
        end
        p.after_generation_extensions.each do |e|
          pipeline.add_after_generation_extension( e )
        end
      end
    end

    def execute_pipeline(on_reload = false)
      FileUtils.mkdir_p( site.config.output_dir )
      FileUtils.mkdir_p( site.config.tmp_dir )
      pipeline.execute( site, on_reload )
    end

    def configure_compass 
      site.images_dir      = File.join( site.config.dir, 'images' )
      site.fonts_dir       = File.join( site.config.dir, 'fonts' )
      site.sass_dir        = File.join( site.config.dir, 'stylesheets' )
      site.css_dir         = File.join( site.config.output_dir, 'stylesheets' )
      site.javascripts_dir = File.join( site.config.dir, 'javascripts' )

      ::Compass.configuration do |config|
        config.project_type = :stand_alone
        config.environment = site.profile
        config.project_path = site.config.dir
        config.sass_path = File.join(config.project_path, 'stylesheets')
        config.http_path = site.base_url || site.config.options.base_url || '/'
        config.css_path = File.join(site.output_dir, 'stylesheets')
        config.javascripts_path = File.join(site.output_dir, 'javascripts')
        config.http_javascripts_dir = File.join(config.http_path, 'javascripts')
        config.http_stylesheets_dir = File.join(config.http_path, 'stylesheets')
        config.sprite_load_path = [config.images_path]
        config.http_images_dir = File.join(config.http_path, 'images')
        config.images_path = File.join(config.project_path, 'images')
        config.fonts_dir = 'fonts'
        config.fonts_path = File.join(config.project_path, 'fonts')
        config.http_fonts_dir = File.join(config.http_path, 'fonts')

        if config.generated_images_dir == config.default_for('generated_images_dir')
          config.generated_images_dir = File.join(site.output_dir, 'images')
          config.http_generated_images_dir = File.join(config.http_path, 'images')
        end

        config.line_comments = lambda do
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
        end.call

        config.output_style = lambda do
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
        end.call

        config.relative_assets = false
      end

      compass_config_file = File.join(site.config.config_dir, 'compass.rb')
      if File.exists? compass_config_file
        ::Compass.add_configuration ::Compass::Configuration::FileData.new_from_file(compass_config_file) 
      end 
      ::Compass.configuration # return for use elsewhere

      # TODO: Should we add an on_stylesheet_error block?  
    end

    def load_pages
      $LOG.debug "layout_page_loader.load_all :post" if config.debug
      @layout_page_loader.load_all( :post )
      $LOG.debug "site_page_loader.load_all :inline" if config.debug 
      @site_page_loader.load_all( :inline )
    end

    def generate_output
      require 'ruby-prof'
      RubyProf.start unless RubyProf.running?
      FileUtils.mkdir_p( site.config.output_dir )
      return_value = [Awestruct::ExceptionHelper::EXITCODES[:success]]
      begin
        return_value = Parallel.map(@site.pages, site.generation) do |page|
          start_time = DateTime.now
          return_value = generate_page( page )
          $LOG.trace "Total time generating #{page.output_path} #{DateTime.now.to_time - start_time.to_time} seconds" if config.verbose

          return_value
        end
      rescue Exception => e
        Awestruct::ExceptionHelper.log_error e
        return_value = [Awestruct::ExceptionHelper::EXITCODES[:generation_error]]
      end
      result = RubyProf.stop
      printer = RubyProf::MultiPrinter.new(result)
      printer.print(path: File.join(config.dir, '.awestruct'), profile: 'profile')

      if return_value.nil? || return_value.include?(Awestruct::ExceptionHelper::EXITCODES[:generation_error])
        $LOG.error 'An error occurred during output generation, all pages may not have completed during generation'
        exit Awestruct::ExceptionHelper::EXITCODES[:generation_error]
      end
      site.engine.pipeline.execute_after_generation(site)
    end

    def generate_page(page, produce_output=true)
      if produce_output
        generated_path = File.join( site.config.output_dir, page.output_path )
        $LOG.debug "Generating: #{generated_path}" if config.verbose && config.debug

        c = ''
        begin
          c = page.rendered_content
          c = site.engine.pipeline.apply_transformers( site, page, c )

          FileUtils.mkdir_p( File.dirname( generated_path ) )

          File.open( generated_path, 'wb' ) do |file|
            file << c
          end
        rescue Exception => e
          Awestruct::ExceptionHelper.log_building_error e, page.relative_source_path
        ensure
          return Awestruct::ExceptionHelper::EXITCODES[:generation_error] if c.include? 'Backtrace:'
        end
        Awestruct::ExceptionHelper::EXITCODES[:success]
      elsif site.config.track_dependencies
        if page.dependencies.load!
          $LOG.debug "Cached:     #{generated_path}" if config.debug
        else
          $LOG.debug "Analyzing:  #{generated_path}" if config.debug
          page.rendered_content
        end
        return Awestruct::ExceptionHelper::EXITCODES[:success]
      end
    end

    # path - relative to output dir
    def page_by_source_path(path)
      if path.include? '_layout'
        site.layouts.find { |p| p.source_path.to_s.include? path }
      elsif path.include? '_partial'
        site.partials.find { |p| p.source_path.to_s.include? path }
      else
        site.pages.find { |p| p.source_path.to_s.include? path }
      end
    end

    def generate_page_and_dependencies(page)

      if page.nil?
        return
      end

      if !page.output_path.nil? && !page.is_partial? && !page.__is_layout
        generate_page_internal(page)
      end

      regen_pages = page_dependencies( page )

      $LOG.debug 'Starting regeneration of content dependent pages:' if regen_pages.size > 0 && config.debug

      regen_pages.each do |p|
        $LOG.info "Regenerating page #{p.output_path}"
        generate_page_internal(p)
      end

      regen_pages
    end

    def page_dependencies(page)
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
    end

    def run_auto_for_non_page(file, generate = true)
      if File.extname(file) == '.rb'
        load file
      end
      @pipeline = Pipeline.new
      load_yamls
      load_pipeline
      execute_pipeline(true)

      if generate
        site.pages.each do |p|
          generate_page_internal(p)
        end
      end
      site.pages
    end

    def generate_page_internal(p)
      unless p.output_path.nil? || p.__is_layout || !p.stale_output?(p.output_path)
        generate_page( p )
      end
    end

    ####
    ## compat with awestruct 0.2.x
    ####

    def load_page(path, options={})
      page = @site_page_loader.load_page( path )
      if options[:relative_path]
        fixed_relative_path = ( options[:relative_path].nil? ? nil : File.join( '', options[:relative_path] ) )
        page.relative_path = fixed_relative_path
      end
      page
    end

    def load_site_page(relative_path)
      if Pathname.new(relative_path).absolute?
        load_page( relative_path )
      else
        load_page( Pathname.new(File.join(site.config.dir, relative_path)) )
      end
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
