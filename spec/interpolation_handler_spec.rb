require 'hashery'
require 'awestruct/handlers/string_handler'
require 'awestruct/handlers/interpolation_handler'

describe Awestruct::Handlers::InterpolationHandler do

  before :all do
    @site = Hashery::OpenCascade[ { :encoding=>false } ]
  end

  it "should interpolate content when rendered" do 
    handler = build_handler( 'This is #{cheese}' )

    context = Hashery::OpenCascade[ { :cheese=>'swiss' } ] 
    content = handler.rendered_content( context )
    content.should == 'This is swiss'
  end

  it "should correctly interpolate complicated stuff that includes regular expressions [Issue #139]" do
    input = %q(url = url.replace(/\/?#$/, '');)
    handler = build_handler( input )
    content = handler.rendered_content( Hashery::OpenCascade[] )
    content.should == input
  end

  def build_handler( input )
    Awestruct::Handlers::InterpolationHandler.new( @site, Awestruct::Handlers::StringHandler.new( @site, input ) )
  end
end


