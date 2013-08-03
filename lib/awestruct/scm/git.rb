require 'open3'

module Awestruct
  module Scm
    class Git
      def uncommitted_changes?(source_dir)
        result = Open3.popen3('git status --porcelain', :chdir => source_dir) do |stdin, stdout, stderr, wait_thr|
          stdout.read.chomp =~ /^\s*([AM?]+)/
        end
        !result.nil?
      end
    end
  end
end
