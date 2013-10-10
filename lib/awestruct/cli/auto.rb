#require 'guard/awestruct'
require 'awestruct/util/exception_helper'

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
        listener = Listen.to( @config.dir, :relative_paths=>true, :latency=>0.5, :force_polling=>force_polling ) do |modified, added, removed|
          modified.each do |path|
            engine = ::Awestruct::Engine.instance
            unless ( path =~ %r(#{File.basename( engine.config.output_dir) }) || path =~ /.awestruct/ )
              begin
                if path.eql? current_path
                  unless generate_thread.nil?
                    $LOG.info "Same path triggered, stopping previous generation" if generate_thread.alive? && $LOG.info?
                    generate_thread.kill
                  end
                else
                  generate_thread.join unless generate_thread.nil?
                  current_path = path
                end

                generate_thread = Thread.new {
                  begin
                    engine.generate_page_by_output_path( path )
                    $LOG.info "Generating.... done!" if $LOG.info?
                  rescue => e
                    ExceptionHelper.log_building_error e, path
                  end
                }
              rescue => e
                ExceptionHelper.log_building_error e, path
              end
            end
          end
        end
        listener.ignore( %r(\.awestruct) )
        listener.ignore( %r(^#{File.basename( @config.tmp_dir )}) )
        listener.ignore( %r(^#{File.basename( @config.output_dir )}) )
        listener.start
        sleep
      end

    end

  end
end
