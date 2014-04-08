require 'logger'
require 'fileutils'
require 'tilt'

require 'awestruct/util/exception_helper'
require 'awestruct/handlers/template/asciidoc'

module Awestruct
  module TestData
    def test_data_dir(test)
      File.join File.dirname(__FILE__), 'test-data', test
    end
  end
end

RSpec.configure do |config|
  config.include Awestruct::TestData
  config.before :suite do
    FileUtils.mkdir_p( File.join(File.dirname(__FILE__), 'test-config/.awestruct'))
    $LOG = Logger.new(File.join(File.dirname(__FILE__), 'test-config/.awestruct/test.log'))
    ::Tilt.register ::Awestruct::Tilt::AsciidoctorTemplate, 'adoc', 'asciidoc', 'ad'
  end
  config.after :suite do
    FileUtils.rm_rf File.join(File.dirname(__FILE__), 'test-config/.awestruct')
  end
  config.before :each do
    Awestruct::ExceptionHelper.class_variable_set :@@failed, false
  end
end

