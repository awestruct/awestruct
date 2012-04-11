require 'git'

module Awestruct
  module Commands

    class GitHubPages
      def initialize( site_path )
        @site_path = site_path
        @git       = Git.open(".")
      end

      def run
        @git.status.changed.empty? ? publish_site : message_for(:existing_changes)
      end

      private
      def publish_site
        current_branch = @git.branch
        checkout_pages_branch
        add_and_commit_site @site_path
        push_and_restore current_branch
      end

      def checkout_pages_branch
        @git.branch('gh-pages').checkout
      end

      def add_and_commit_site( path )
        @git.with_working( path ) do
          @git.add(".")
          begin
            @git.commit("Published to gh-pages.")
          rescue Git::GitExecuteError => e
            $stderr.puts "Can't commit. #{e}."
          end
        end
      end

      def push_and_restore( branch )
        @git.reset_hard
        @git.push( 'origin', 'gh-pages' )
        @git.checkout( branch )
      end

      def message_for( key )
        $stderr.puts case key
        when :existing_changes 
          "You have uncommitted changes in the working branch. Please commit or stash them."
        else 
          "An error occured."
        end
      end
    end
  end
end
