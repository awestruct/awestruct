# in your site.yml specify
#
# google_analytics:
#  account: UA-something
#  anonymizeIp: true
#  bounceTime: 15
#
# of course only "account" is required

module Awestruct
  module Extensions
    module GoogleAnalytics

      def google_analytics_async()
        # deprecated
        $LOG.warn "google_analytics_async is deprecated. Please use google_analytics or google_analytics_universal." if $LOG.warn?
        google_analytics()
      end

      def google_analytics(options={})
        options = defaults(options)

        html = ''
        html += %Q(<script type="text/javascript">\n)
        html += %Q(var _gaq = _gaq || [];\n)
        html += %Q(_gaq.push(['_setAccount','#{options[:account]}']);\n)
        html += %Q(_gaq.push(['_gat._anonymizeIp']);\n) if options[:anonymizeIp]
        html += %Q(_gaq.push(['_trackPageview']);\n)
        html += %Q(setTimeout("_gaq.push(['_trackEvent','#{options[:bounceTime]}_seconds','read'])", #{options[:bounceTime]}000);\n) if options[:bounceTime]
        html += %Q[(function() {\n]
        html += %Q( var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;\n)
        html += %Q( ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';\n)
        html += %Q( var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);\n)
        html += %Q[})();\n</script>\n]
        html
      end

      def google_analytics_universal(options={})
        options = defaults(options)

        html = ''
        html += %Q(<script>\n)
        html += %Q( (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\n
                    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\n
                    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\n
                    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');\n )
        html += %Q(\n)
        html += %Q(ga('create', '#{options[:account]}', 'auto');\n)
        html += %Q(ga('send', 'pageview');\n)
        html += %Q(ga('set', 'anonymizeIp', true);\n) if options[:anonymizeIp]
        html += %Q(setTimeout("ga('send', 'event', 'read', '#{options[:bounceTime]} seconds')", #{options[:bounceTime]}000);\n) if options[:bounceTime]
        html += %Q(\n)
        html += %Q(</script>\n)
        html
      end

      private

      def defaults(options)
        options = site.google_analytics.merge(options) if site.google_analytics.is_a?(Hash)
        options = Hash[options.map{ |k, v| [k.to_sym, v] }]

        if site.google_analytics_anonymize
          # deprecated
          $LOG.warn "Syntax has changed to site.google_analytics = { :anonymizeIp => true }" if $LOG.warn?
          options[:anonymizeIp] = true
        end
        if site.google_analytics.is_a?(String)
          # deprecated
          $LOG.warn "Syntax has changed to site.google_analytics = { :account => '#{site.google_analytics}' }" if $LOG.warn?
          options[:account] = site.google_analytics
        end

        options
      end
    end
  end
end
