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
      def run(deploy_config)
        if deploy_config['uncommitted'] == true
          publish_site
        else
          scm = deploy_config['scm'] || 'git'
          #require "awestruct/scm/#{scm}"
          scm_class = Object.const_get('Awestruct').const_get('Scm').const_get(scm.slice(0, 1).capitalize + scm.slice(1..-1))
          scm_class.new.uncommitted_changes?(deploy_config['source_dir']) ? existing_changes() : publish_site()
        end
      end

      def publish_site
        $LOG.error( "#{self.class.name}#publish_site not implemented." ) if $LOG.error?
      end

      def existing_changes
        $LOG.error UNCOMMITTED_CHANGES if $LOG.error?
      end
    end
  end
end
