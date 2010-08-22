
require 'sha1'

module Awestruct
  module Extensions
    module IntenseDebate

      def intense_debate_comments(post_id=nil)
        post_id_fragment = '';
        if ( ! post_id.nil? )
          post_id_fragment="='#{SHA1.hexdigest(post_id)}'"
        end
        html = %Q(<script>\n)
        html += %Q(  var idcomments_acct='#{site.intense_debate_acct}';\n)
        html += %Q(  var idcomments_post_id#{post_id_fragment};\n)
        html += %Q(  var idcomments_post_url;\n)
        html += %Q(</script>\n)
        html += %Q(<span id="IDCommentsPostTitle" style="display:none"></span>\n)
        html += %Q(<script type='text/javascript' src='http://www.intensedebate.com/js/genericCommentWrapperV2.js'></script>\n)
        html 
      end

      def intense_debate_comments_link(post_id=nil, post_url=nil)
        post_id_fragment = '';
        if ( ! post_id.nil? )
          post_id_fragment="='#{SHA1.hexdigest(post_id)}'"
        end
        post_url_fragment = '';
        if ( ! post_url.nil? )
          post_url_fragment="='#{post_url}'"
        end
        html = %Q(<script>\n)
        html += %Q(  var idcomments_acct='#{site.intense_debate_acct}';\n)
        html += %Q(  var idcomments_post_id#{post_id_fragment};\n)
        html += %Q(  var idcomments_post_url#{post_url_fragment};\n)
        html += %Q(</script>\n)
        html += %Q(<script type='text/javascript' src='http://www.intensedebate.com/js/genericLinkWrapperV2.js'></script>\n)
        html
      end
    end
  end

end
