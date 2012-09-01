

module Awestruct

  class PageLoader

    attr_reader :site
    attr_reader :root_dir

    def initialize(site, target=:pages)
      @site   = site
      @target = target

      @root_dir = site.config.dir
      if ( @target == :layouts )
        @root_dir = Pathname.new( File.join( root_dir, '_layouts/' ) )
      end
    end

    def ignore?(path)
      site.config.ignore.include?( path )
    end

    def load_all(prepare=:inline)
      raise "No such dir #{root_dir}" unless File.directory?(root_dir)
      pages = []
      root_dir.find do |path|
        if ( path == root_dir )
          puts "skip #{path}" if (site.config.verbose)
          next
        end
        basename = File.basename( path )
        if ( basename == '.htaccess' )
          #special case
        elsif ( basename =~ /^[_.]/ )
          puts "skip #{path} and prune" if (site.config.verbose)
          Find.prune
          next
        end
        relative_path = path.relative_path_from( root_dir ).to_s
        if ignore?(relative_path)
          puts "skip ignored #{path} and prune" if (site.config.verbose)
          Find.prune
          next
        end
        unless path.directory?
          puts "loading #{relative_path}" if (site.config.verbose)
          page = load_page( path, prepare )
          if ( page )
            #puts "loaded! #{path} and added to site"
            #inherit_front_matter( page )
            site.send( @target ) << page
            pages << page
          end
        end
      end
      if ( prepare == :post )
        pages.each{|p| p.prepare!}
      end
    end

    def load_page(path,prepare=:inline)
      pathname = case( path )
        when Pathname then pathname = path
        else pathname = Pathname.new( path )
      end
      chain = site.engine.pipeline.handler_chains[ path ]
      return nil if chain.nil?
      handler = chain.create(site, Pathname.new(path))
      p = Page.new( site, handler )
      if ( @target == :layouts )
        p.__is_layout = true
      else
        p.__is_layout = false
      end
      p.track_dependencies!
      if prepare == :inline
        p.prepare!
      end
      p
    end

  end

end
