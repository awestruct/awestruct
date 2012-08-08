require 'awestruct/deploy/base_deploy'

module Awestruct
  module Deploy
    class S3Deploy < Base
      def initialize( site_config, deploy_config )
        @site_path = site_config.output_dir
      end
    end
  end
end

Awestruct::Deployers.instance[ :s3 ] = Awestruct::Deploy::S3Deploy

