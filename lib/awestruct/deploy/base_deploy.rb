require 'awestruct/deployers'
require 'awestruct/compatibility'
require 'awestruct/util/exception_helper'

Dir[ File.join( File.dirname(__FILE__), '..', 'scm', '*.rb' ) ].each do |f|
  begin
    require f
  rescue LoadError => e
    raise e 'Something horribly, horribly wrong has happened'
  end
end


module Awestruct
  module Deploy
    class Base
      UNCOMMITTED_CHANGES = 'You have uncommitted changes in the working branch. Please commit or stash them.'

      def initialize(site_config, deploy_config)
        # Add a single front slash at the end of output dir
        @site_path = File.join( site_config.output_dir, '/' ).gsub(/^\w:\//, '/')
        @gzip = deploy_config['gzip']
        @gzip_level = deploy_config['gzip_level'] || Zlib::BEST_COMPRESSION
        @source_dir = deploy_config['source_dir'] || site_config.dir
        @ignore_uncommitted = deploy_config['uncommitted']
        init_scm(deploy_config['scm'] || 'git')
      end

      def run
        if ExceptionHelper.build_failed?
          ExceptionHelper.log_message 'Not running deploy due to build failure'
          return
        end

        if @ignore_uncommitted == true
          compress_site
          publish_site
        else
          if @scm.uncommitted_changes? @source_dir
            existing_changes
          else
            compress_site
            publish_site
          end
        end
      end

      def publish_site
        $LOG.error( "#{self.class.name}#publish_site not implemented." ) if $LOG.error?
      end

      def existing_changes
        $LOG.error UNCOMMITTED_CHANGES if $LOG.error?
      end

      def compress_site
        if @gzip
          gzip_site @site_path
        end
      end

      def gzip_site(site_path)
        Dir.glob("#{site_path}/**/*") do |item|
          next if item == '.' or item == '..'
          ext = File.extname(item)
          if !ext.empty?
            ext_sym = ext[1..-1].to_sym
            case ext_sym
            when :css, :js, :html
              require 'zlib'
              if !is_gzipped item
                gzip_file(item, @gzip_level)
              end
            end
          end
        end
      end

      def gzip_file(filename, level)
        $LOG.debug "Gzipping File #{filename}"
        Zlib::GzipWriter.open("#{filename}.gz", level) do |gz|
          gz.mtime = File.mtime(filename)
          gz.orig_name = filename
          gz.write File.binread(filename)
        end
        File.rename("#{filename}.gz", "#{filename}")
      end

      def is_gzipped(filename)
        begin
          File.open("#{filename}") do |f|
            Zlib::GzipReader.new(f)
            true
          end
        rescue
          false
        end
      end

      def init_scm type
        begin
          clazz = Object.const_get('Awestruct').const_get('Scm').const_get(type.capitalize)
          @scm = clazz.new
        rescue
          ExceptionHelper.log_message( "Could not resolve class for scm type: #{type}" )
          ExceptionHelper.mark_failed
        end
      end
    end
  end
end
