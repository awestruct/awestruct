require 'awestruct/handler_chain'
require 'shellwords'
require 'open3'

if RUBY_VERSION.start_with? "1.9"
  Encoding.default_external = "UTF-8"
else
  puts RUBY_VERSION
end

module Awestruct
  module Handlers
    class BaseHandler

      attr_reader :site
      attr_reader :delegate

      def initialize(site, delegate=nil)
        @site     = site
        @delegate = delegate
      end

      def stale?
        return @delegate.stale? if @delegate
        false
      end

      def input_mtime(page)
        return @delegate.input_mtime(page) if @delegate
        0
      end

      def simple_name
        return @delegate.simple_name if @delegate
        nil
      end

      def relative_source_path 
        return @delegate.relative_source_path if @delegate
        nil
      end

      def output_filename
        return @delegate.output_filename if @delegate
        nil
      end

      def output_path
        ( p = relative_source_path ) if relative_source_path
        ( of = output_filename ) if output_filename
        return File.join( File.dirname( p ), output_filename ) if ( p && of )
        nil
      end

      def output_extension
        return @delegate.output_extension if @delegate 
        return File.extname( output_filename ) unless output_filename.nil?
        nil
      end

      def path
        return @delegate.path if @delegate
        nil
      end

      def front_matter
        return @delegate.front_matter if @delegate
        {}
      end

      def content_syntax
        return @delegate.content_syntax if @delegate
        :none
      end

      def raw_content
        return @delegate.raw_content if @delegate
        nil
      end

      def rendered_content(context, with_layouts=true)
        return @delegate.rendered_content(context, with_layouts) if @delegate
        nil
      end

      def content_line_offset
        return @delegate.content_line_offset if @delegate
        0
      end

      def inherit_front_matter(page)
        return @delegate.inherit_front_matter(page) if @delegate
      end

      def dependencies
        return @delegate.dependencies if @delegate
        []
      end

      def to_chain
        chain = [ self ]
        chain += @delegate.to_chain if @delegate
        chain.flatten
      end

      def execute_shell(command, input=nil)
        Open3.popen3(Shellwords.escape( command )) do |stdin, stdout, _|
          stdin.puts input unless input.nil?
          stdin.close
          out = stdout.read
        end
      rescue Errno::EPIPE
        ""
      end

    end
  end
end
