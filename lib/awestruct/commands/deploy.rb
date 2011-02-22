require 'open3'

module Awestruct
  module Commands

    class Deploy
      def initialize(site_path, opts)
        @site_path = File.join( site_path, '/' )
        @host      = opts['host']
        @path      = File.join( opts['path'], '/' )
      end

      def run
        cmd = "rsync -r -l -i --no-p --no-g --chmod=Dg+s,ug+w--delete #{@site_path} #{@host}:#{@path}"
        puts "running #{cmd}"
        Open3.popen3( cmd ) do |stdin, stdout, stderr| 
          stdin.close
          threads = []
          threads << Thread.new(stdout) do |i|
            while ( ! i.eof? )
              line = i.readline 
              puts line
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
