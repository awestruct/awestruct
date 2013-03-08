require 'awestruct/deployers'
require 'git'

module Awestruct
  module Deploy
    class Base
      UNCOMMITTED_CHANGES = "You have uncommitted changes in the working branch. Please commit or stash them."
      def run(deploy_config)
        if deploy_config['uncommitted'] == true
          publish_site
        else
          git.status.changed.empty? ? publish_site : existing_changes
        end
      end

      def git
        @git ||= ::Git.open('.')
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
