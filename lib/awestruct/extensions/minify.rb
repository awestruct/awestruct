require 'shellwords'
require 'fileutils'
require 'htmlcompressor'
require 'yuicompressor'

##
# Awestruct:Extensions:Minify is a transformer that minimizes JavaScript, CSS and HTML files.
# The transform runs on the rendered stream before it's written to the output path.
#
# Minification is performed by the following libraries:
#
#   htmlcompressor (minifies HTML): http://code.google.com/p/htmlcompressor/
#   uglifier (minifies javascript): http://github.com/lautis/uglifier
#   pngcrush (minifies PNG): http://pmt.sourceforge.net/pngcrush/
#
# These commands must be available on your PATH in order to use them.
#
# This class is loaded as a transformer into the Awestruct pipeline. The
# constructor accepts an array of symbols representing the file types to minimize.
#
#   transformer Awestruct::Extensions::Minify.new
#
# This transform recognizes the following symbols:
#
#   :js - JavaScript files with extension .js
#   :html - HTML files with extension .html
#   :png - PNG files with extension .png
#
# If no types are specified, the default value [:js] is used.
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
# 
# Note that any hypen (-) must be represented as an underscore (_) in the configuration.

module Awestruct
  module Extensions
    class Minify

      def initialize(types = [ :js ])
        @types = types
      end

      def transform(site, page, input)
        if site.minify
          ext = File.extname(page.output_path)
          if !ext.empty?
            ext_sym = ext[1..-1].to_sym
            if @types.include?(ext_sym)
              case ext_sym
              when :html
                print "minifying html #{page.output_path}"
                input = htmlcompressor(page, input, site.minify_html_opts)
              when :css
                # TODO: Figure out how to do this is sass / less and document it
                #print "minifying css #{page.output_path}"
                #input = yuicompressor_css(page, input)
              when :js
                print "minifying js #{page.output_path}"
                input = js_compressor(page, input)
              when :png
                print "minifying png #{page.output_path}"
                input = pngcrush(page, input)
              end
            end
          end
        end
        input
      end

      private

      class JSCompressor
        def compress( input )
          Uglifier.new(:mangle => false).compile(input)
        end
      end

      def htmlcompressor(page, input, minify_html_opts)
        opts = minify_html_opts.nil? ? {}:minify_html_opts
        compressor(page, input, HtmlCompressor::Compressor.new(opts))
      end

      def js_compressor(page, input)
        compressor(page, input, YUICompressor, :compress_js)
      end

      def compressor(page, input, compressor, method = :compress)
        output = compressor.send(method, input)

        input_len = input.length
        output_len = output.length

        if input_len > output_len
          $LOG.debug " %d bytes -> %d bytes = %.1f%%" % [ input_len, output_len, 100 * output_len/input_len ] if $LOG.debug?
          output
        else
          $LOG.debug " no gain" if $LOG.debug?
          input
        end
      end

      def pngcrush(page, input)
        filename = page.source_path
        cmd = Shellwords.escape("pngcrush #{filename} /tmp/pngcrush")
        `#{cmd}`
        if $?.exitstatus != 0
          raise "Failed to execute pngcrush: #{cmd}"
        end
        output = File.read('/tmp/pngcrush')

        input_len = File.stat(filename).size
        output_len = output.length

        if input_len > output_len
          $LOG.debug " %d bytes -> %d bytes = %.1f%%" % [ input_len, output_len, 100 * output_len/input_len ] if $LOG.debug?
          output
        else
          $LOG.debug " no gain" if $LOG.debug?
          input
        end
      end
    end

  end
end
