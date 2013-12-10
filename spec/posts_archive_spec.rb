require 'awestruct/extensions/posts'
require 'awestruct/util/inflector'
require 'hashery'

describe Awestruct::Extensions::Posts do

  it "should have an empty string as the default path prefix" do
    extension = Awestruct::Extensions::Posts.new
    extension.path_prefix.should == ''
  end

  it "should have :posts as the default assign_to" do
    extension = Awestruct::Extensions::Posts.new('/posts')
    extension.assign_to.should == :posts
  end

  it "should have 'posts' as a layout by default" do
    extension = Awestruct::Extensions::Posts.new('/posts', :posts)
    extension.default_layout.should eql 'post' 
  end

  it "should have a nil archive template by default" do
    extension = Awestruct::Extensions::Posts.new('/posts', :posts)
    extension.archive_path.should be_nil
  end

  it "should accept a path prefix parameter" do
    extension = Awestruct::Extensions::Posts.new( '/posts' )
    extension.path_prefix.should == '/posts'
  end

  it "should accept a method assignment name parameter" do
    extension = Awestruct::Extensions::Posts.new( '/posts', :news )
    extension.assign_to.should == :news
  end

  it "should accept an archive path prefix" do
    extension = Awestruct::Extensions::Posts.new( '/posts', :news, '/archive/index', '/archive' )
    extension.archive_path.should == '/archive'
  end

  it "should accept an archive template file path parameter" do
    extension = Awestruct::Extensions::Posts.new( '/posts', :news, '/archive/index' )
    extension.archive_template.should == '/archive/index'
  end

  it "should accept a default layout for post pages" do
    extension = Awestruct::Extensions::Posts.new( '/posts', :news, nil, nil, :default_layout => 'blog' )
    extension.archive_path.should be_nil
    extension.archive_template.should be_nil
    extension.default_layout.should == 'blog'
  end

  it "should assign default layout if specified to post without layout" do
    extension = Awestruct::Extensions::Posts.new( '/posts', :news, nil, nil, :default_layout => 'blog' )
    site = Hashery::OpenCascade[ { :encoding=>false } ]
    page = __create_page( 2012, 8, 9, '/posts/double-post.md' )
    page.stub(:layout).and_return(nil)
    page.should_receive(:layout=).with('blog')
    page.stub(:slug).and_return(nil, 'double-post')
    page.should_receive(:slug=).with('double-post')
    page.should_receive(:output_path=).with('/posts/2012/08/09/double-post.html')

    site.pages = [page]
    extension.execute(site)
    site.news.size.should == 1
    site.news.first.should == page
  end

  describe Awestruct::Extensions::Posts::Archive do

    before :each do
      @archive = Awestruct::Extensions::Posts::Archive.new
      @page = __create_page( 2012, 8, 9 )
      @archive << @page
    end

    it "should store pages by year, month, and day" do
      @archive.posts[2012].should_not be_nil
      @archive.posts[2012][8][9][0].should == @page
    end

    it "should use the provided template when generating the archive" do
      engine = double("Engine")
      template = double("Template")
      template.should_receive( :archive= ).with( @archive.posts[2012][8][9] )
      template.should_receive( :output_path= ).with( '/archive/2012/8/9/index.html' )
      engine.should_receive( :find_and_load_site_page ).with( '/archive/index' ).and_return( template )
      @archive.generate_pages( engine, '/archive/index', '/archive' ) 
    end

  end

  def __create_page(year, month, day, path = nil)
    page = double( "Page for #{year}-#{month}-#{day}" )
    page.stub(:date?).and_return( true )
    page.stub(:date=).with(anything())
    page.stub_chain(:date, :year).and_return( year )
    page.stub_chain(:date, :month).and_return( month )
    page.stub_chain(:date, :day).and_return( day )
    page.stub(:relative_source_path).and_return( path ) if path
    page.stub(:create_context)
    page.stub(:sequence).and_return( nil )
    page.stub(:source_path).and_return( '.' )
    page
  end

end
