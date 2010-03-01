
module Awestruct
  module Extensions
    module IntenseDebate

      def intense_debate_comments()
        html = %Q(<script>\n)
        html += %Q(  var idcomments_acct='#{site.intense_debate_acct}';\n)
        html += %Q(  var idcomments_post_id;\n)
        html += %Q(  var idcomments_post_url;\n)
        html += %Q(</script>\n)
        html += %Q(<span id="IDCommentsPostTitle" style="display:none"></span>\n)
        html += %Q(<script type='text/javascript' src='http://www.intensedebate.com/js/genericCommentWrapperV2.js'></script>\n)
        html 
      end
    end
  end

end
