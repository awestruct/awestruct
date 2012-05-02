require 'guard'
require 'guard/guard'

require 'awestruct/engine'

module Guard
  class Awestruct < Guard

    def initialize(watchers=[], options={})
      super
    end

    def start
      @engine = ::Awestruct::Engine.instance
    end

    def stop
    end

    def reload
    end

    def run_all
    end

    def run_on_change(paths)
      paths.each do |path|
        unless ( path =~ %r(#{File.basename( @engine.config.output_dir) }) || path =~ /.awestruct/ )
          @engine.generate_page_by_output_path( path )
        end
      end
    end

    def run_on_deletion(paths)
    end

  end
end
