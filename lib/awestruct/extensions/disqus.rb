module Awestruct
  module Extensions
    class Disqus

      def execute(site)
        site.pages.each{ |p| p.extend Disqus }
      end

      module Disqus
        def disqus_comments()
          developer = (site.disqus_developer) ? 'var disqus_developer = 1;' : ''
          %Q{
            <div id="disqus_thread"></div>
            <script type="text/javascript">
            var disqus_shortname = '#{site.disqus}';
            var disqus_url = "#{site.base_url}/#{self.url}";
            #{developer}
            (function() {
              var dsq = document.createElement("script"); dsq.type = "text/javascript"; dsq.async = true;
              dsq.src = "http://#{site.disqus}.disqus.com/embed.js";
              (document.getElementsByTagName("head")[0] || document.getElementsByTagName("body")[0]).appendChild(dsq);
            })();
            </script>
            <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript=#{site.disqus}">comments powered by Disqus.</a></noscript>
          }
        end

        def disqus_comments_link()
          %Q{ <a href="#{self.url}#disqus_thread">Comments</a> }
        end

        def disqus_comments_count()
          %Q{
            <script type="text/javascript">
            var disqus_shortname = '#{site.disqus}';
            (function () {
              var s = document.createElement('script'); s.async = true;
              s.src = "http://disqus.com/forums/#{site.disqus}/count.js";
              (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
            }());
            </script>
          }
        end
      end
    end
  end

end
