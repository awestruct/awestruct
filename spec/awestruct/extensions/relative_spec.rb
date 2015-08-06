require 'awestruct/extensions/relative'
require 'ostruct'

describe Awestruct::Extensions::Relative do
  let(:dummy_class) { Class.new { extend Awestruct::Extensions::Relative } }

  context 'with file extension' do
    let (:page) { OpenStruct.new(:output_path => 'site/base/path/file.html') }

    it "should should not  have '/' at the end if there is a file extension" do
      expect(dummy_class.relative('site/base/path/another_file.html', page)).to eql 'another_file.html'
    end
  end

  context 'without file extension' do
    let (:page) { OpenStruct.new(:output_path => 'site/base/path/file.html') }

    it "should should not  have '/' at the end if there is a file extension" do
      expect(dummy_class.relative('site/base/path/some_directory', page)).to eql 'some_directory/'
    end
  end
end