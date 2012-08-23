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
        $stderr.puts( "#{self.class.name}#publish_site not implemented." )
      end

      def existing_changes
        $stderr.puts UNCOMMITTED_CHANGES
      end
    end
  end
end
