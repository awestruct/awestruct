require 'fileutils'

module Awestruct
  module Extensions
    class Minify

      def initialize(types = [ :css, :js ])
        @types = types
      end

      def transform(site, page, input)
        if site.minify
          ext = File.extname(page.output_path)[1..-1].to_sym
          if @types.include?(ext)
            case ext
            when :html
              print "minifying html #{page.output_path}"
              htmlcompressor(page, input)
            when :css
              print "minifying css #{page.output_path}"
              yuicompressor(page, input, :css)
            when :js
              print "minifying js #{page.output_path}"
              yuicompressor(page, input, :js)
            when :png
              print "minifying png #{page.output_path}"
              pngcrush(page, input)
            else
              input
            end
          end
        end
        input
      end

      private

      def htmlcompressor(page, input)
        output = ''
        Open3.popen3("htmlcompressor --remove-intertag-spaces") do |stdin, stdout, stderr|
          threads = []
          threads << Thread.new(stdout) do |o|
            while ( ! o.eof? )
              output << o.readline
            end
          end
          threads << Thread.new(stdin) do |i|
            i.write input
            i.close
          end
          threads.each{ |t|t.join }
        end

        input_len = input.length
        output_len = output.length

        if input_len > output_len
          puts " %d bytes -> %d bytes = %.1f%%" % [ input_len, output_len, 100 * output_len/input_len ]
          output
        else
          puts " no gain"
          input
        end
      end

      def yuicompressor(page, input, type)
        output = ''
        Open3.popen3("yuicompressor --type #{type}") do |stdin, stdout, stderr|
          threads = []
          threads << Thread.new(stdout) do |o|
            while ( ! o.eof? )
              output << o.readline
            end
          end
          threads << Thread.new(stdin) do |i|
            i.write input
            i.close
          end
          threads.each{ |t|t.join }
        end

        input_len = input.length
        output_len = output.length

        if input_len > output_len
          puts " %d bytes -> %d bytes = %.1f%%" % [ input_len, output_len, 100 * output_len/input_len ]
          output
        else
          puts " no gain"
          input
        end
      end

      def pngcrush(page, input)
        filename = page.source_path
        cmd = "pngcrush #{filename} /tmp/pngcrush"
        `#{cmd}`
        if $?.exitstatus != 0
          raise "Failed to execute pngcrush: #{cmd}"
        end
        output = File.read('/tmp/pngcrush')

        input_len = File.stat(filename).size
        output_len = output.length

        if input_len > output_len
          puts " %d bytes -> %d bytes = %.1f%%" % [ input_len, output_len, 100 * output_len/input_len ]
          output
        else
          puts " no gain"
          input
        end
      end
    end

  end
end
