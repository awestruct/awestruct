
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
        html += %Q(var _gaq = [['_setAccount','#{site.google_analytics}'],)
        if site.google_analytics_anonymize
          html += %Q(['_gat._anonymizeIp'],)
        end
        html += %Q(['_trackPageview']];\n)
        html += %Q[(function(d, t) {\n]
        html += %Q( var g = d.createElement(t),\n)
        html += %Q(     s = d.getElementsByTagName(t)[0];\n)
        html += %Q( g.async = true;\n)
        html += %Q( g.src = ('https:' == location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';\n)
        html += %Q( s.parentNode.insertBefore(g, s);\n)
        html += %Q[})(document, 'script');\n</script>\n]
        html
      end
    end
  end

end
