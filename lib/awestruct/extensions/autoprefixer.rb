require 'autoprefixer-rails'

module Awestruct
  module Extensions
    class AutoPrefixer
      def initialize
        if ExecJS.runtime.name.start_with? "therubyracer"
          $LOG.warn "WARNING: ExecJS is using 'therubyracer' backend. " \
            "My testing shows it usually deadlocking due to threaded " \
            "execution here (tested with 0.12.3). " \
            "AutoPrefixer and Awestruct coffee handler are both using " \
            "ExecJS and there seems to be some concurrency issue with " \
            "'therubyracer'. See " \
            "https://github.com/sstephenson/execjs/issues/205"
        end
      end

      def transform(site, page, input)
        if page.output_extension == '.css'
          fix_encoding(input)
          input = AutoprefixerRails.process(
            input,
            from: page.source_path,
            **site.autoprefixer
          ).css
        end
        return input
      end

      # some files throw "An error occurred: "\xE2" from ASCII-8BIT to UTF-8" when
      #   processed with ExecJS/nodejs backend like this one:
      #   https://github.com/HubSpot/tether/blob/ad295ad/docs/css/intro.css
      def fix_encoding(str)
        if str.encoding == ::Encoding::ASCII_8BIT
          f_enc = str.match(/\A@charset "([-A-Za-z0-9_]+)";/)
          if f_enc && f_enc[1]
            str.force_encoding(::Encoding.find(f_enc[1]))
          else
            str.force_encoding(::Encoding.default_external)
          end
        end
      end
    end
  end
end
