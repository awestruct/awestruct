require 'awestruct/page'
require 'awestruct/extensions/disqus'

describe Awestruct::Extensions::Disqus do

  before :all do
    @site = Awestruct::AStruct.new :encoding=>false, :disqus=>'spec', :base_url=>'http://example.org'
    @disqus = Awestruct::Extensions::Disqus.new 
  end

  before :each do
    @page = Awestruct::Page.new @site
    @page.date = Time.utc(2012,12,8)
    @page.slug = 'spec-post'
    @page.url = '/posts/2012/12/08/spec-post/'
    @site.disqus_generate_id = true
    @site.pages = [@page]
    @disqus.execute(@site)
  end

  it "should assign the disqus short name" do
    @page.disqus_comments().should match(/var disqus_shortname = '#{@site.disqus}';/) 
    @page.disqus_comments_count().should match(/var disqus_shortname = '#{@site.disqus}';/) 
  end

  it "should generate an identifier if necessary when id generation is enabled" do
    @page.disqus_comments().should match(/var disqus_identifier = "12bb52d0776930e01e9a410fd14f13382778e449";/)
    @page.disqus_comments_link().should match(/ data-disqus-identifier="12bb52d0776930e01e9a410fd14f13382778e449"/)
  end

  it "should use the identifier specified in the page" do
    @page.disqus_identifier = @page.slug
    @page.disqus_comments().should match(/var disqus_identifier = "#{@page.disqus_identifier}";/)
    @page.disqus_comments_link().should match(/ data-disqus-identifier="#{@page.disqus_identifier}"/)
  end

  it "should have a null identifier if no identifier is specified and id generation is disabled" do
    @site.disqus_generate_id = false
    @page.disqus_comments().should match(/var disqus_identifier = null;/)
    @page.disqus_comments_link().should_not match(/ data-disqus-identifier=/)
  end

end
