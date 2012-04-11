require 'git'

module Awestruct
  module Commands

    class GitHubPages
      def initialize( site_path )
        @site_path = site_path
        @git       = Git.open(".")
      end

      def run
        return message_and_fail( :no_branch ) unless @git.is_branch?('gh-pages')
        return message_and_fail( :existing_changes ) if !@git.status.changed.empty?
        publish_site
      end

      private
      def publish_site
        current_branch = @git.branch
        @git.checkout('gh-pages')
        @git.with_working( @site_path ) do
          @git.add(".")
          begin
            @git.commit("Published to gh-pages.")
          rescue Git::GitExecuteError => e
            $stderr.puts "Can't commit. #{e}."
          end
        end
        @git.reset_hard
        @git.push( 'origin', 'gh-pages' )
        @git.checkout( current_branch )
      end

      def message_and_fail( message )
        $stderr.puts message_for( message )
        return false
      end

      def message_for( err )
        case err
        when :no_branch        
          "No gh-pages branch exists. See http://help.github.com/pages/ for more info."
        when :existing_changes 
          "You have uncommitted changes in the working branch. Please commit or stash them."
        else 
          "An error occured."
        end
      end
    end
  end
end
