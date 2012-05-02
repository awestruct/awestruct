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
      end
  
      def run()
        deploy_type = :rsync
  
        if ( deploy_config['host'] == 'github_pages' )
          deploy_type = :github_pages
        end
  
        deployer_class = Awestruct::Deployers.instance[ deploy_type ]
  
        if ( deployer_class.nil? )
          $stderr.puts "Unable to locate correct deployer for #{deploy_type}"
          return
        end
  
        deployer = deployer_class.new( site_config, deploy_config )
        deployer.run
        
      end
    end

  end
end
