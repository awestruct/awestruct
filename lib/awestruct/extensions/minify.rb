require 'fileutils'

##
# Awestruct:Extensions:Minify is a transformer that minimizes JavaScript, CSS and HTML files.
# The transform runs on the rendered stream before it's written to the output path.
#
# Minification is performed by the following three libraries:
#
#   htmlcompressor (minifies HTML): http://code.google.com/p/htmlcompressor/
#   yuicompressor (minifies JavaScript and CSS): http://developer.yahoo.com/yui/compressor/
#   pngcrush (minifies PNG): http://pmt.sourceforge.net/pngcrush/
#
# These commands must be available on your PATH in order to use them.
#
# This class is loaded as a transformer in the Awestruct pipeline. The
# constructor accepts an array of symbols representing the file types to minimize.
#
#   extension Awestruct::Extensions::Minify.new
#
# This transform recognizes the following symbols:
#
#   :css - CSS files with extension .css
#   :js - JavaScript files with extension .js
#   :html - HTML files with extension .html
#   :png - PNG files with extension .png
#
# If no types are specified, the default value [:css, :js] is used.
# 
# In addition to registering the transformer in the pipeline, it must be enabled
# by setting the following site property in _ext/config.yml:
#
#   minify: true
#
# You can limit activation to one or more profiles: 
#
#   profiles:
#     production:
#       minify: true
#
# You can also configure the option arguments passed to the compressor programs. Here's
# how you specify options arguments for the htmlcompressor command:
#
#   minify_html_opts:
#     remove_intertag_spaces: true
#     compress_js: true
#     compress_css: true
# 
# Note that any hypen (-) must be represented as an underscore (_) in the configuration.

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
              htmlcompressor(page, input, site.minify_html_opts)
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
          else
            input
          end
        else
          input
        end
      end

      private

      def htmlcompressor(page, input, minify_html_opts)
        output = ''
        cmd = "htmlcompressor"
        if minify_html_opts
          minify_html_opts.each do |p, v|
            # boolean options are simple flags (i.e., do not accept values)
            if v === true
              cmd += " --#{p.gsub('_', '-')}"
            elsif not v === false
              cmd += " --#{p.gsub('_', '-')}=#{v}"
            end
          end
        end
        Open3.popen3(cmd) do |stdin, stdout, stderr|
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
