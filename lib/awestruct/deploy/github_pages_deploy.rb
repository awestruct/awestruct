require 'awestruct/deploy/base_deploy'
require 'awestruct/util/exception_helper'
require 'git'

module Awestruct
  module Deploy
    class GitHubPagesDeploy < Base
      def initialize(site_config, deploy_config)
        super
        @branch = deploy_config['branch'] || 'gh-pages'
        @repo = deploy_config['repository'] || 'origin'
      end

      def publish_site
        tmp_branch = '__awestruct_deploy__'
        detached_branch = nil

        original_branch = git.current_branch

        # detect a detached state
        # values include (no branch), (detached from x), etc
        if original_branch.start_with? '('
          detached_branch = git.log(1).first.sha
          git.branch(original_branch = tmp_branch).checkout
        end

        # work in a branch, then revert to current branch
        git.branch(@branch).checkout
        add_and_commit_site @site_path
        git.push(@repo, @branch)

        if detached_branch
          git.checkout detached_branch
          git.branch(original_branch).delete
        else
          git.checkout original_branch
        end
      end

      private
      def add_and_commit_site(path)
        git.with_working(path) do
          git.add(".")
          begin
            git.commit("Published #{@branch} to GitHub pages.")
          rescue ::Git::GitExecuteError => e
            ExceptionHelper.log_message "Can't commit. #{e}."
            ExceptionHelper.mark_failed
          end
        end
        git.reset_hard
      end

      def git
        @git ||= ::Git.open('.')
      end
    end
  end
end

Awestruct::Deployers.instance[:github_pages] = Awestruct::Deploy::GitHubPagesDeploy
