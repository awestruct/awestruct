require 'awestruct/deploy/s3_deploy'
require 'awestruct/deploy/rsync_deploy'
require 'awestruct/deploy/github_pages_deploy'

module Awestruct
  module CLI

    class Deploy

      attr_accessor :site_config
      attr_accessor :deploy_config

      def initialize(site_config, deploy_config)
        @site_config   = site_config
        @deploy_config = deploy_config
        @deploy_config['type'] ||= (is_github? ? :github_pages : :rsync)
        $LOG.info "Deploying to #{deploy_type}" if $LOG.info?
      end

      def deploy_type
        deploy_config['type']
      end
  
      def run()
        deployer_class = Awestruct::Deployers.instance[ deploy_type.to_sym ]
  
        if ( deployer_class.nil? )
          $LOG.error "Unable to locate correct deployer for #{deploy_type}" if $LOG.error?
          $LOG.error "Deployers available for #{::Awestruct::Deployers.instance.collect {|k,v| "#{v} (#{k})"}.join(', ')}" if $LOG.error?
          return
        end
  
        deployer = deployer_class.new( site_config, deploy_config )
        deployer.run
      end

      private
      def is_github?
        deploy_config['host'].to_s == 'github_pages' || deploy_config['host'].to_s == 'github_pages'
      end
    end

  end
end
