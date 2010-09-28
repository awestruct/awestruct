module Awestruct
  module Extensions
    class Disqus

      def execute(site)
        site.pages.each{|p| p.extend Disqus }
      end

      module Disqus
        def disqus_comments()
          'comments'
        end

        def disqus_comments_link()
          'comments link'
        end

# http://bakery.cakephp.org/articles/view/disqus-comment-system-integration-helper

# <div id="disqus_thread"></div>
# <script type="text/javascript">
#   /**
#     * var disqus_identifier; [Optional but recommended: Define a unique identifier (e.g. post id or slug) for this thread] 
#     */
#   (function() {
#    var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
#    dsq.src = 'http://vafer.disqus.com/embed.js';
#    (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
#   })();
# </script>
# <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript=vafer">comments powered by Disqus.</a></noscript>
# <a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>

# <script type="text/javascript">
# var disqus_shortname = 'vafer';
# (function () {
#   var s = document.createElement('script'); s.async = true;
#   s.src = 'http://disqus.com/forums/vafer/count.js';
#   (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
# }());
# </script>

# <a href="http://example.com/my_article.html#disqus_thread">Comments</a>

# post_id = self.post_id ? self.post_id : Digest::SHA1.hexdigest( self.url )

      end
    end
  end

end
