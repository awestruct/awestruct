#require 'guard/awestruct'

require 'listen'

module Awestruct
  module CLI
    class Auto

      def initialize(config)
        @config = config
      end

      def run()
        force_polling = ( RUBY_PLATFORM =~ /mingw/ ? true : false )
        listener = Listen.to( @config.dir, :relative_paths=>true, :latency=>0.5, :force_polling=>force_polling )
        listener.ignore( %r(\.awestruct) )
        listener.ignore( %r(^#{File.basename( @config.tmp_dir )}) )
        listener.ignore( %r(^#{File.basename( @config.output_dir )}) )
        listener.change do |modified, added, removed|
          modified.each do |path|
            engine = ::Awestruct::Engine.instance
            unless ( path =~ %r(#{File.basename( engine.config.output_dir) }) || path =~ /.awestruct/ )
              begin
                engine.generate_page_by_output_path( path )
              rescue => e
                puts e
                puts e.backtrace
              end
            end
          end
        end
        listener.start(false)
      end

    end

  end
end
