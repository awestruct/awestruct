
module Awestruct

  class Config

    attr_accessor :layouts_dir
    attr_accessor :config_dir
    attr_accessor :extension_dir
    attr_accessor :output_dir
    attr_accessor :skin_dir
    attr_accessor :ignore

    def initialize()
      @layouts_dir    = '_layouts'
      @config_dir     = '_config'
      @output_dir     = '_site'
      @extension_dir  = '_ext'
      @skin_dir       = '_skin'
      @ignore         = [ ]
    end

  end

end
