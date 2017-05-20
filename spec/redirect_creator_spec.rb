require 'awestruct/page'
require 'awestruct/extensions/redirect_creator'
require 'awestruct/logger'

# create a global logget to avoid errors when executing internal classes using the logger
$LOG = Logger.new(Awestruct::AwestructLoggerMultiIO.new)
$LOG.level = Logger::DEBUG 
$LOG.formatter = Awestruct::AwestructLogFormatter.new

describe Awestruct::Extensions::RedirectCreator do

  it "Without a redirect.yml config the extension should exit" do
    site = Awestruct::AStruct.new :encoding=>false, :base_url=>'http://example.org'
    redirect_creator = Awestruct::Extensions::RedirectCreator.new     
    lambda { redirect_creator.execute(site) }.should raise_error(SystemExit, "Redirect config _config/redirects.yml does not exist")
  end

  it "Without a template file the extension should exit" do
    site = Awestruct::AStruct.new :encoding=>false, :base_url=>'http://example.org'

    redirects = { "foo" => "http://bar.com" }
    site["redirects"] = redirects

    redirect_creator = Awestruct::Extensions::RedirectCreator.new     
    lambda { redirect_creator.execute(site) }.should raise_error(SystemExit, /RedirectCreator is configured in pipeline, but redirect template/)
  end

  it "A redirect page should be created" do
    # create a test site
    site = Awestruct::AStruct.new :encoding=>false, :base_url=>'http://example.org'
    site.pages = []
    site.config = {:track_dependencies => false}

    # add the redirect config programatically 
    redirects = { "foo" => "http://bar.com" }
    site["redirects"] = redirects
    site["redirect_creator_template"] = File.join(File.dirname(__FILE__), "test-data", "redirects.template") 

    # create the extension under test  
    redirect_creator = Awestruct::Extensions::RedirectCreator.new     
     
    # verify a age gets created
    expect(site.pages.size).to be == 0  
    redirect_creator.execute(site)
    expect(site.pages.size).to be == 1 

    # verify the page has the right path
    created_page = site.pages[0]
    expect(created_page.output_filename).to match("foo.html")

    # verifiy the page contains the redirect target
    context = Awestruct::Context.new ({:page => created_page, :site => site}) 
    expect(created_page.rendered_content(context)).to match("http://bar.com")
  end

end
