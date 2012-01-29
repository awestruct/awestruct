module Awestruct
  module Extensions
    class Flattr

      def execute(site)
        site.pages.each{|p| p.extend Flattrable }
      end

      module Flattrable
        def flattr_javascript()
          html = %Q|<script type='text/javascript'> /* <![CDATA[ */     (function() {\n|
          html += %Q|var s = document.createElement('script'), t = document.getElementsByTagName('script')[0];|
          html += %Q|s.type = 'text/javascript';\n|
          html += %Q|s.async = true;\n|
          html += %Q|s.src = 'http://api.flattr.com/js/0.6/load.js?mode=auto&uid=#{site.flattr_username}&category=text';\n|
          html += %Q|t.parentNode.insertBefore(s, t);\n|
          html += %Q|})(); /* ]]> */ </script>|
          html
        end
        def flattr_large_counter(param={})
          url = param[:url] ? param[:url] : site.base_url + self.url
          title = param[:title] ? param[:title] : self.title
          category = param[:category] ? param[:category] : "text"
          tags = param[:tags] ? "tags:" + param[:tags] + ";" : ""
          html = %Q|<a class="FlattrButton" style="display:none;" href="#{url}" title="#{title}" |
          html += %Q|rev="flattr;uid:#{site.flattr_username};category:#{category};#{tags}"></a>|
          html
        end
        def flattr_compact_counter(param={})
          url = param[:url] ? param[:url] : site.base_url + self.url
          title = param[:title] ? param[:title] : self.title
          category = param[:category] ? param[:category] : "text"
          tags = param[:tags] ? "tags:" + param[:tags] + ";" : ""
          html = %Q|<a class="FlattrButton" style="display:none;" href="#{url}" title="#{title}" |
          html += %Q|rev="flattr;button:compact;uid:#{site.flattr_username};category:#{category};#{tags}"></a>|
          html
        end
      end

    end
  end
end
