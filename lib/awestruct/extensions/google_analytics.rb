module Awestruct
  module Extensions
    module GoogleAnalytics

      def google_analytics()
        html = ''
        html += %Q(<script type="text/javascript">\n)
        html += %Q(var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");\n)
        html += %Q(document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));\n)
        html += %Q(</script>\n)
        html += %Q(<script type="text/javascript">\n)
        html += %Q(try {\n)
        html += %Q(var pageTracker = _gat._getTracker("#{site.google_analytics}");\n)
        html += %Q(pageTracker._trackPageview();\n)
        html += %Q(} catch(err) {}</script>\n)
        html
      end

      def google_analytics_async()
        html = ''
        html += %Q(<script type="text/javascript">\n)
        html += %Q(var _gaq = _gaq || [];\n)
        html += %Q(_gaq.push(['_setAccount','#{site.google_analytics}']);\n)
        if site.google_analytics_anonymize
          html += %Q(_gaq.push(['_gat._anonymizeIp']);\n)
        end
        html += %Q(_gaq.push(['_trackPageview']);\n)
        html += %Q[(function() {\n]
        html += %Q( var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;\n)
        html += %Q( ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';\n)
        html += %Q( var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);\n)
        html += %Q[})();\n</script>\n]
        html
      end

    end
  end
end
