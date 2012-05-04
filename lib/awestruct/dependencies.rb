
module Awestruct
  class Dependencies

    attr_reader :page
    attr_reader :dependencies
    attr_reader :dependents


    def self.top_page
      @pages ||= []
      @pages.first
    end

    def self.push_page(page)
      if ( top_page.nil? )
        page.dependencies.clear
      else
        top_page.dependencies.add_dependency( page )
      end
      @pages.push( page )
    end

    def self.pop_page
      page = @pages.pop
      if ( @pages.empty? && ! page.nil? )
        page.dependencies.persist!
      end
    end


    def self.track_dependency(dep)
      return if top_page.nil? 
      return if top_page == dep
      top_page.dependencies.add_dependency(dep)
    end

    def initialize(page)
      @page = page
      @dependencies = Set.new
      @dependents   = Set.new
    end

    def <<(dep)
      add_dependency( dep )
    end

    def add_dependency(dep)
      return if @page.do_not_track_dependencies
      return if @page.output_path.nil?
      return if dep == @page
      @dependencies << dep
      dep.dependencies.add_dependent( page )
    end

    def add_dependent(dep)
      @dependents << dep
    end

    def remove_dependent(dep)
      @dependents.delete( dep )
    end

    def clear
      @dependencies.clear
      @dependents.each{|d| d.remove_dependent( page ) }
    end

    def persist!
      return if  page.output_path.nil? || page.output_path == ''
      file = File.join( @page.site.config.dir, '.awestruct', 'dependency-cache', page.output_path )
      FileUtils.mkdir_p( File.dirname( file ) )
      File.open( file, 'w' ) do |file|
        @dependencies.collect{|e| e.relative_source_path }.uniq.each do |d|
          file.puts d unless d.nil?
        end
      end
    end

    def load!
      return if  page.output_path.nil? || page.output_path == ''
      file = File.join( @page.site.config.dir, '.awestruct', 'dependency-cache', page.output_path )
      #puts "load #{file}"
      if ( File.exist?( file ) )
        File.open( file, 'r' ) do |file|
          file.lines.each do |line|
            d = find_page_by_path( line.strip )
            add_dependency( d ) unless d.nil?
          end
        end
        return true
      end
      false
    end

    def find_page_by_path(path)
      page.site.pages_by_relative_source_path[ path ]
    end


  end
end
