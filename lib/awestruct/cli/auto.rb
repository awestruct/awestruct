#require 'guard/awestruct'

require 'listen'

module Awestruct
  module CLI
    class Auto

      def initialize(config)
        @config = config
      end

      def run()
        generate_thread = nil
        current_path = nil

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
                if path.eql? current_path
                  unless generate_thread.nil?
                    puts "Same path triggered, stopping previous generation" if generate_thread.alive?
                    generate_thread.kill
                  end
                else
                  generate_thread.join unless generate_thread.nil?
                  current_path = path
                end

                generate_thread = Thread.new {
                  begin
                    engine.generate_page_by_output_path( path )
                    puts "Generating.... done!"
                  rescue => e
                    puts e
                    puts e.backtrace
                  end
                }
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
