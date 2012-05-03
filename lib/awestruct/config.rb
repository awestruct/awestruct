
module Awestruct

  class Config

    attr_accessor :dir
    attr_accessor :layouts_dir
    attr_accessor :config_dir
    attr_accessor :extension_dir
    attr_accessor :input_dir
    attr_accessor :output_dir
    attr_accessor :skin_dir
    attr_accessor :tmp_dir
    attr_accessor :ignore
    attr_accessor :track_dependencies

    attr_accessor :images_dir
    attr_accessor :stylesheets_dir

    def initialize(dir = Dir.pwd)
      @dir            = Pathname.new( dir ) 
      @layouts_dir    = Pathname.new( File.join(dir, '_layouts') )
      @config_dir     = Pathname.new( File.join(dir, '_config') )
      @input_dir      = Pathname.new( File.join(dir, '') )
      @output_dir     = Pathname.new( File.join(dir, '_site') )
      @extension_dir  = Pathname.new( File.join(dir, '_ext') )
      @skin_dir       = Pathname.new( File.join(dir, '_skin') )
      @tmp_dir        = Pathname.new( File.join(dir, '_tmp') ) 

      @images_dir      = Pathname.new( File.join(dir, 'images') ) 
      @stylesheets_dir = Pathname.new( File.join(dir, 'stylesheets') ) 

      @ignore         = File.exists?(ignore_file = File.join(dir, ".awestruct_ignore")) ? Dir[*IO.read(ignore_file).each_line.map(&:strip)] : []

      @track_dependencies = false
    end

  end

end
