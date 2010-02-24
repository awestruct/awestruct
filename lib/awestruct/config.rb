
module Awestruct

  class Config

    attr_accessor :layouts_dir
    attr_accessor :config_dir
    attr_accessor :output_dir
    attr_accessor :ignore

    def initialize()
      @layouts_dir = '_layouts'
      @config_dir  = '_config'
      @output_dir  = '_site'
      @ignore      = [ ]
    end

  end

end
