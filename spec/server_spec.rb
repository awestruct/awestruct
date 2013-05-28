require 'awestruct/rack/app'
require 'rack/test'

describe Awestruct::Rack::App do
  include Rack::Test::Methods

  def app
    Awestruct::Rack::App.new(Pathname.new( File.dirname(__FILE__) + '/test-data'))
  end

  describe "HTML media type" do
    it "should return text/html" do
      get('/index.html')
      last_response.headers['Content-Type'].should == 'text/html'
    end
  end

  describe "Directory redirect" do
    it "should redirect to /" do
      get('/subdir')
      last_response.headers['location'].should == '/subdir/'
      last_response.instance_variable_get('@body').should == ['Redirecting to: /subdir']
      last_response.body.should == 'Redirecting to: /subdir'
    end
  end

  describe "CSS media type" do
    it "should return text/css" do
      get('/stylesheets/screen.css')
      last_response.headers['Content-Type'].should == 'text/css'
    end
  end

  describe "PNG media type" do
    it "should return image/png" do
      get('/images/logo.png')
      last_response.headers['Content-Type'].should == 'image/png'
    end
  end

  describe "JavaScript media type" do
    it "should return application/javascript" do
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

  describe "Directory with no index file" do
    it "should return a 404 status code" do
      get('/images/')
      last_response.status.should == 404
    end
  end
end
