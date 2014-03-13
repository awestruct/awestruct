module Awestruct
  module Extensions
    module GoogleUniversalAnalytics

      def google_analytics()
        html = ''
        html += %Q(<script>\n)
        html += %Q( (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\n
                    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\n
                    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\n
                    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');\n )
        html += %Q(\n)
        html += %Q(ga('create', '#{site.google_analytics}', 'auto');\n)
        html += %Q(ga('send', 'pageview');\n)
        html += %Q(\n)
        html += %Q(</script>\n)
        html
      end

    end
  end
end
