require 'digest/sha1'

module Awestruct
  module Extensions
    class IntenseDebate

      def execute(site)
        site.pages.each{|p| p.extend IntenseDebatable }
      end

      module IntenseDebatable
        def intense_debate_comments()
          post_id = self.post_id ? self.post_id : Digest::SHA1.hexdigest( self.url )
          html = %Q(<script>\n)
          html += %Q(  var idcomments_acct='#{site.intense_debate_acct}';\n)
          html += %Q(  var idcomments_post_id='#{post_id}';\n )
          html += %Q(  var idcomments_post_url='#{site.intense_debate_base_url || site.base_url}#{self.url}';\n)
          html += %Q(</script>\n)
          html += %Q(<span id="IDCommentsPostTitle" style="display:none"></span>\n)
          html += %Q(<script type='text/javascript' src='http://www.intensedebate.com/js/genericCommentWrapperV2.js'></script>\n)
          html
        end

        def intense_debate_comments_link()
          post_id = self.post_id ? self.post_id : Digest::SHA1.hexdigest( self.url )
          html = %Q(<script>\n)
          html += %Q(  var idcomments_acct='#{site.intense_debate_acct}';\n)
          html += %Q(  var idcomments_post_id='#{post_id}';\n )
          html += %Q(  var idcomments_post_url='#{self.url}';\n)
          html += %Q(</script>\n)
          html += %Q(<script type='text/javascript' src='http://www.intensedebate.com/js/genericLinkWrapperV2.js'></script>\n)
          html
        end

      end
    end
  end
end
