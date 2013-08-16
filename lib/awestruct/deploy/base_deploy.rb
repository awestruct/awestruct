require 'awestruct/deployers'
Dir[ File.join( File.dirname(__FILE__), '..', 'scm' '*.rb' ) ].each do |f|
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
      end

      def run(deploy_config)
        if deploy_config['uncommitted'] == true
          compress_site
          publish_site
        else
          scm = deploy_config['scm'] || 'git'
          #require "awestruct/scm/#{scm}"
          scm_class = Object.const_get('Awestruct').const_get('Scm').const_get(scm.slice(0, 1).capitalize + scm.slice(1..-1))
          if scm_class.new.uncommitted_changes?(deploy_config['source_dir'])
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
          gzip_site
        end
      end

      def gzip_site
        require 'zlib'
        Dir.glob("#{@site_path}/**/*") do |item|
          next if item == '.' or item == '..'
          ext = File.extname(item)
          if !ext.empty?
            ext_sym = ext[1..-1].to_sym
            case ext_sym
            when :css, :js, :html
              gzip_file item
            end
          end
        end
      end

      def gzip_file( filename )
        if !is_gzipped filename
          $LOG.debug "Gzipping File #{filename}"
          Zlib::GzipWriter.open("#{filename}.gz") do |gz|
            gz.mtime = File.mtime(filename)
            gz.orig_name = filename
            gz.write IO.binread(filename)
          end
          File.rename("#{filename}.gz", "#{filename}")
        end
      end

      def is_gzipped( filename )
        begin
          File.open("#{filename}") do |f|
            Zlib::GzipReader.new(f)
            true
          end
        rescue
          false
        end
      end
    end
  end
end
