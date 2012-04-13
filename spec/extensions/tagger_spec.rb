require 'spec_helper'
require 'awestruct/extensions/tagger'

describe Awestruct::Extensions::Tagger do

  before :each do
  end

  it "should work" do
    Awestruct::Extensions::Tagger.new( :podcasts, 
                                       '/podcasts/index', 
                                       '/podcasts/tags', 
                                       :per_page=>5 )
  end

end

