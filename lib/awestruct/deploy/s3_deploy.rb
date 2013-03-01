require 'awestruct/deploy/base_deploy'
require 'ruby-s3cmd'

module Awestruct
  module Deploy
    class S3Deploy < Base
      def initialize( site_config, deploy_config )
        @site_path = site_config.output_dir
        @bucket = deploy_config['bucket']
      end

      def publish_site
        $LOG.info "Syncing #{@site_path} to bucket #{@bucket}" if $LOG.info?
        s3cmd = RubyS3Cmd::S3Cmd.new
        s3cmd.sync("#{@site_path}/", @bucket)
        $LOG.info "DONE" if $LOG.info?
      end
    end
  end
end

Awestruct::Deployers.instance[ :s3 ] = Awestruct::Deploy::S3Deploy

