require 'awestruct/deploy/base_deploy'

module Awestruct
  module Deploy
    class S3Deploy < Base
      def initialize( site_config, deploy_config )
        super
        @bucket = deploy_config['bucket']
        @metadata = deploy_config['metadata']
      end

      def publish_site
        $LOG.info "Syncing #{@site_path} to bucket #{@bucket}" if $LOG.info?
        if @metadata and !@metadata.empty?
          @metadata.each do |fileType, headers|
            # Build the add-header command because the s3cmd-dsl gem doesn't support multi-headers
            headerCmd = ""
            if headers && !headers.empty?
              headers.each do |key, value|
                headerCmd << add_header(key, value)
              end
            end
            # If gzip is enabled, add 'Content-Encoding: gzip' on js, css and html files
            if @gzip and ['js', 'css', 'html'].include? fileType
              headerCmd << add_header("Content-Encoding", "gzip")
            end
            # Sync files of current type with specified headers
            s3_sync(@site_path, @bucket, "*", "*.#{fileType}", headerCmd)
          end
        end
        # If gzip is enabled, add 'Content-Encoding: gzip' on not processed js, css and html files
        if @gzip
          remainingFileType = ['js', 'css', 'html'].find_all { |fileType| !@metadata.keys.include? fileType }
          remainingFileType.each do |fileType|
            headerCmd = add_header("Content-Encoding", "gzip")
            s3_sync(@site_path, @bucket, "*", "*.#{fileType}", headerCmd)
          end
        end
        # Finally, sync others files
        s3_sync(@site_path, @bucket)
        $LOG.info "DONE" if $LOG.info?
      end

      def add_header(key, value)
        " --add-header '#{key}:#{value}'"
      end

      def s3_sync(site_path, bucket, exclude = nil, include = nil, headersCmd = nil)
        cmd="s3cmd sync '#{site_path}' '#{bucket}'"
        cmd << " --exclude '#{exclude}'" if exclude
        cmd << " --include '#{include}'" if include
        cmd << " #{headersCmd}" if headersCmd
        $LOG.info "Execute #{cmd}"
        `#{cmd}`
      end
    end
  end
end

Awestruct::Deployers.instance[ :s3 ] = Awestruct::Deploy::S3Deploy

