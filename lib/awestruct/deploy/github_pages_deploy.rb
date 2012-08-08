require 'awestruct/deploy/base_deploy'

module Awestruct
  module Deploy
    class GitHubPagesDeploy < Base
      def initialize( site_config, deploy_config )
        @site_path = site_config.output_dir
        @branch    = deploy_config[ 'branch' ] || 'gh-pages'
      end

      def publish_site
        current_branch = git.current_branch
        git.branch( @branch ).checkout
        add_and_commit_site @site_path
        git.push( 'origin', @branch )
        git.checkout( current_branch )
      end

      private
      def add_and_commit_site( path )
        git.with_working( path ) do
          git.add(".")
          begin
            git.commit("Published #{@branch} to GitHub pages.")
          rescue ::Git::GitExecuteError => e
            $stderr.puts "Can't commit. #{e}."
          end
        end
        git.reset_hard
      end
    end
  end
end

Awestruct::Deployers.instance[ :github_pages ] = Awestruct::Deploy::GitHubPagesDeploy
