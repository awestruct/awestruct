
require 'awestruct/layouts'
require 'awestruct/page'
require 'awestruct/handlers/file_handler'
require 'awestruct/handlers/tilt_handler'

require 'hashery'

describe Awestruct::Layouts do

  it "should be able to index layouts by simple name and output extension" do
    dir = Pathname.new( test_data_dir 'handlers' )
    site = Hashery::OpenCascade[ { :dir=>dir } ]
    file_handler = Awestruct::Handlers::FileHandler.new( site, File.join( dir, 'haml-layout.html.haml' ) )
    haml_handler = Awestruct::Handlers::TiltHandler.new( site, file_handler )
    page = Awestruct::Page.new( nil, haml_handler )
    
    layouts = Awestruct::Layouts.new
    layouts << page

    located = layouts[0]
    located.should_not be_nil
    located.class.should == Awestruct::Page
    located.simple_name.should == 'haml-layout'

    located = layouts.find_matching( 'haml-layout', '.html' )
    located.should_not be_nil
    located.class.should == Awestruct::Page
    located.simple_name.should == 'haml-layout'
  end

end
