require 'guard/awestruct'

module Awestruct
  module CLI
    class Auto

      def initialize(config)
        @config = config
      end

      def run()
        Guard.setup
        Guard.start( :guardfile_contents=>guardfile_contents,
                     :watchdir=>@config.dir,
                     :watch_all_modifications=>true )
      end

      def guardfile_contents
        ignored = [ 
          "'.awestruct'",
          "'#{File.basename( @config.tmp_dir )}'",
          "'#{File.basename( @config.output_dir )}'",
        ] 
        c = ''
        c += "guard :awestruct do\n"
        c += "  watch %r(.*)\n"
        c += "  ignore_paths #{ignored.join(', ')}"
        c += "end\n"
        c
      end
    end

  end
end
