require 'awestruct/cli/options'

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

    attr_accessor :verbose
    attr_accessor :quiet
    attr_accessor :options
    attr_accessor :debug
    attr_accessor :perf

    def initialize(opts = Awestruct::CLI::Options.new)
      @dir             = Pathname.new(File.expand_path(Pathname.new( opts.source_dir )))
      @layouts_dir     = Pathname.new( File.join(@dir, '_layouts') )
      @config_dir      = Pathname.new( File.join(@dir, '_config') )
      @input_dir       = @dir
      @output_dir      = Pathname.new(File.expand_path(Pathname.new( opts.output_dir )))
      @extension_dir   = Pathname.new( File.join(@dir, '_ext') )
      @skin_dir        = Pathname.new( File.join(@dir, '_skin') )
      @tmp_dir         = Pathname.new( File.join(@dir, '_tmp') )
      @images_dir      = Pathname.new( File.join(@dir, 'images') )
      @stylesheets_dir = Pathname.new( File.join(@dir, 'stylesheets') )

      @options = opts
      @verbose = opts.verbose
      @debug = opts.debug
      @perf = opts.perf_log

      # Dir[] doesn't like empty list
      ignore_file = File.join(@dir, ".awestruct_ignore")
      if File.exist?(ignore_file)
        ignore_stmts = IO.read(ignore_file).each_line.map(&:strip)
      end

      @ignore = (!ignore_stmts.nil? and ignore_stmts.size > 0) ? Dir[*ignore_stmts] : []

      @track_dependencies = false
    end

  end

end
