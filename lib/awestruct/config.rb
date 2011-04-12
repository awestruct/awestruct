
module Awestruct

  class Config

    attr_accessor :layouts_dir
    attr_accessor :config_dir
    attr_accessor :extension_dir
    attr_accessor :input_dir
    attr_accessor :output_dir
    attr_accessor :skin_dir
    attr_accessor :ignore

    def initialize(dir)
      @layouts_dir    = File.join(dir, '_layouts')
      @config_dir     = File.join(dir, '_config')
      @input_dir      = File.join(dir, '')
      @output_dir     = File.join(dir, '_site')
      @extension_dir  = File.join(dir, '_ext')
      @skin_dir       = File.join(dir, '_skin')
      @ignore         = [ ]
    end

  end

end
