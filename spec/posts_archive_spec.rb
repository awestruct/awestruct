require 'awestruct/extensions/posts'

describe Awestruct::Extensions::Posts::Archive do

  it "should store pages by year and month" do
    archive = Awestruct::Extensions::Posts::Archive.new
    page = create_page( 2012, 8 )
    archive << page
    archive.posts[2012].should_not be_nil
    archive.posts[2012][8][0].should == page
  end

  def create_page(year, month)
    page = mock
    page.stub_chain(:date, :year).and_return( year )
    page.stub_chain(:date, :month).and_return( month )
    page
  end

end


