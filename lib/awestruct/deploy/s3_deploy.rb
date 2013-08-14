require 'awestruct/deploy/base_deploy'
require 'ruby-s3cmd'

module Awestruct
  module Deploy
    class S3Deploy < Base
      def initialize( site_config, deploy_config )
        @site_path = site_config.output_dir
        @bucket = deploy_config['bucket']
        @gzip = deploy_config['gzip']
      end

      def publish_site
        compress_site
        $LOG.info "Syncing #{@site_path} to bucket #{@bucket}" if $LOG.info?
        s3cmd = RubyS3Cmd::S3Cmd.new
        s3cmd.sync("#{@site_path}/", @bucket)
        $LOG.info "DONE" if $LOG.info?
      end

      def compress_site
        if @gzip
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

Awestruct::Deployers.instance[ :s3 ] = Awestruct::Deploy::S3Deploy

