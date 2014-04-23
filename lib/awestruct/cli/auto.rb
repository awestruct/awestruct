require 'awestruct/util/exception_helper'

require 'listen'
require 'guard/livereload'
require 'compass'

module Awestruct
  module CLI
    class Auto

      def initialize(config, base_url)
        @config = config
        @base_url = base_url
      end

      def run()
        generate_thread = nil
        current_path = nil

        guard = if ( @config.options.livereload )
          guard = Guard::LiveReload.new
          guard.start
          guard
        else
          nil
        end

        force_polling = ( RUBY_PLATFORM =~ /mingw/ ? true : false )
        listener = Listen.to( @config.dir, :latency=>0.5, :force_polling=>force_polling ) do |modified, added, removed|
          modified.each do |path| # path is absolute path
            engine = ::Awestruct::Engine.instance

            unless ( path =~ %r(#{File.basename( engine.config.output_dir) }) || path =~ /.awestruct/ || path =~ /sass-cache/ )
              begin
                $LOG.info "Change detected for file #{path}" if $LOG.info?
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
                    if ( File.extname(path) == '.sass' || File.extname(path) == '.scss' )
                      ::Compass::Commands::UpdateProject.new(engine.site.dir, {}).perform
                    else
                      page = engine.page_by_output_path(path)
                      pages = []
                      if ( page )
                        pages = engine.generate_page_and_dependencies( page )
                      else
                        if File.exist? path
                        # chances are this is an extension or yaml file
                          pages = engine.run_auto_for_non_page(path)
                        end
                      end
                    end

                    $LOG.info "Regeneration finished." if $LOG.info?

                    if ( guard )
                      urls = pages.map do |p|
                        @base_url + p.url.to_s
                      end

                      guard.run_on_modifications(urls)
                    end

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
      end

    end

  end
end
