
#require 'hashery/open_cascade'
require 'awestruct/layouts'
require 'awestruct/astruct'

module Awestruct

  class Site < Awestruct::AStruct

    attr_reader :dir
    attr_reader :output_dir
    attr_reader :tmp_dir

    attr_reader :pages
    attr_reader :layouts

    attr_reader :config
    attr_reader :engine

    def initialize(engine, config)
      @engine = engine
      @pages = []
      @layouts = Layouts.new
      @config = config
      self.encoding = false
    end

    def inspect
      "Site{:dir=>#{dir}}"
    end

    def dir
      @config.dir
    end

    def output_dir
      @config.output_dir
    end

    def tmp_dir
      @config.tmp_dir
    end

    def load_page(path)
      engine.load_path( self, path )
    end


  end

end
