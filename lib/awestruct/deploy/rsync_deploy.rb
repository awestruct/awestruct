require 'awestruct/deployers'

require 'open3'

module Awestruct
  module Deploy
    class RSyncDeploy

      def initialize(site_config, deploy_config)
        @site_path = File.join( site_config.output_dir, '/' ).gsub(/^\w:\//, '/')
        @host      = deploy_config['host']
        @path      = File.join( deploy_config['path'], '/' )
      end

      def run
        cmd = "rsync -r -l -i --no-p --no-g --chmod=Dg+sx,ug+rw --delete #{@site_path} #{@host}:#{@path}"
        Open3.popen3( cmd ) do |stdin, stdout, stderr|
          stdin.close
          threads = []
          threads << Thread.new(stdout) do |i|
            while ( ! i.eof? )
              line = i.readline
              case line[0,9]
              when '<f.sT....'
                puts " updating #{line[10..-1]}"
              when 'cd+++++++'
                puts " creating #{line[10..-1]}"
              when '<f+++++++'
                puts " adding #{line[10..-1]}"
              when '<f..T....'
                # ignoring unchanged files
                # puts " no change to #{line[10..-1]}"
              else
                puts line
              end
            end
          end
          threads << Thread.new(stderr) do |i|
            while ( ! i.eof? )
              line = i.readline
              puts line
            end
          end
          threads.each{|t|t.join}
        end
      end
    end
  end
end

Awestruct::Deployers.instance[ :rsync ] = Awestruct::Deploy::RSyncDeploy
