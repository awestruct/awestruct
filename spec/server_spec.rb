require 'awestruct/rack/app'
require 'rack/test'

describe Awestruct::Rack::App do
  include Rack::Test::Methods

  def app
    Awestruct::Rack::App.new(Pathname.new( File.dirname(__FILE__) + '/test-data'))
  end

  describe "CSS media type" do
    it "should return the proper media type" do
      get('/stylesheets/screen.css')
      last_response.headers['Content-Type'].should == 'text/css'
    end
  end

  describe "PNG media type" do
    it "should return the proper media type" do
      get('/images/logo.png')
      last_response.headers['Content-Type'].should == 'image/png'
    end
  end

  describe "JavaScript media type" do
    it "should return the proper media type" do
      get('/javascript/bootstrap-dropdown.js')
      last_response.headers['Content-Type'].should == 'application/javascript'
    end
  end

  describe "File not found" do
    it "should return a 404 status code" do
      get('/b-is-for-beer.html')
      last_response.status.should == 404
    end
  end
end
