require 'awestruct/deploy/base_deploy'
require 'shellwords'
require 'open3'

module Awestruct
  module Deploy
    class RSyncDeploy < Base

      def initialize(site_config, deploy_config)
        super
        @host      = deploy_config['host']
        @path      = File.join( deploy_config['path'], '/' )
        @exclude   = deploy_config['exclude']
      end

      def publish_site
        exclude_option = (!@exclude.nil? and !@exclude.empty?) ? "--exclude=" + Shellwords.escape(@exclude) : nil
        site_path = Shellwords.escape(@site_path)
        host = Shellwords.escape(@host)
        path = Shellwords.escape(@path)

        cmd = "rsync -r -l -i --no-p --no-g --chmod=Dg+sx,ug+rw --delete #{exclude_option} #{site_path} #{host}:#{path}"

        Open3.popen3( cmd ) do |stdin, stdout, stderr|
          stdin.close
          threads = []
          threads << Thread.new(stdout) do |i|
            while ( ! i.eof? )
              line = i.readline
              head = line[0,9]
              file = line[10..-1].chomp
              case head
              when '<f.sT....'
                $LOG.info " updating #{file}" if $LOG.info?
              when 'cd+++++++'
                $LOG.info " creating #{file}" if $LOG.info?
              when '<f+++++++'
                $LOG.info " adding #{file}" if $LOG.info?
              when '<f..T....'
                # ignoring unchanged files
                $LOG.debug " no change to #{file}" if $LOG.debug?
              when '*deleting'
                $LOG.info " deleting #{file}" if $LOG.info?
              else
                $LOG.debug line if $LOG.debug
              end
            end
          end
          threads << Thread.new(stderr) do |i|
            while ( ! i.eof? )
              line = i.readline
              $LOG.error line if $LOG.error?
            end
          end
          threads.each{|t|t.join}
        end
      end
    end
  end
end

Awestruct::Deployers.instance[ :rsync ] = Awestruct::Deploy::RSyncDeploy
