
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
    end
  end

end
