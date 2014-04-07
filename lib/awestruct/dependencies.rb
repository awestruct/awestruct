module Awestruct
  class Dependencies

    attr_reader :page
    attr_reader :dependencies
    attr_reader :key_dependencies
    attr_reader :dependents
    attr_reader :key_dependents
    attr_reader :content_hash
    attr_reader :key_hash
    attr_reader :has_changed_content
    attr_reader :has_changed_keys


    def self.track_dependencies=(bol)
      @track_dependencies = bol
    end

    def self.should_track_dependencies
      @track_dependencies
    end

    def self.top_page
      @pages ||= []
      @pages.first
    end

    def self.push_page(page)
      $LOG.debug "push #{page.output_path}" if $LOG.debug?
      if ( top_page.nil? )
        $LOG.debug "clearing dependencies" if $LOG.debug?
        page.dependencies.clear
      else
        $LOG.debug "adding page as a dependency to top_page" if $LOG.debug?
        top_page.dependencies.add_dependency( page )
      end
      @pages.push( page )
    end

    def self.pop_page
      page = @pages.pop
      $LOG.debug "pop #{page.output_path} #{@pages.empty?}" if $LOG.debug?
    end


    def self.track_dependency(dep)
      return if top_page.nil?
      return if top_page == dep
      $LOG.debug "dep #{top_page.relative_source_path} - #{dep.relative_source_path}" if $LOG.debug?
      top_page.dependencies.add_dependency(dep)
    end

    def self.track_key_dependency(dep, key)
      return if !Awestruct::Dependencies.should_track_dependencies
      return if top_page.nil?
      return if top_page == dep
      $LOG.debug "dep key #{top_page.relative_source_path} - #{dep.relative_source_path} -> #{key}" if $LOG.debug?
      $LOG.debug "callers #{Kernel.caller}" if $LOG.debug?
      top_page.dependencies.add_key_dependency(dep)
    end


    def initialize(page)
      @page = page
      @dependencies = Set.new
      @key_dependencies   = Set.new
      @dependents   = Set.new
      @key_dependents   = Set.new
      @content_hash = nil
      @key_hash = nil
      @has_changed_content = false
      @has_changed_keys = false
    end

    def key_hash=(key)
      $LOG.debug "key_hash #{key}" if $LOG.debug?
      if @key_hash.nil?
        @has_changed_keys = false
      else
        if key.eql? @key_hash
          @has_changed_keys = false
        else
          @has_changed_keys = true
        end
      end
      @key_hash = key
    end

    def content_hash=(key)
      $LOG.debug "content_hash #{key}" if $LOG.debug?
      if @content_hash.nil?
        @has_changed_content = false
      else
        if key.eql? @content_hash
          @has_changed_content = false
        else
          @has_changed_content = true
        end
      end
      @content_hash = key
    end

    def <<(dep)
      add_dependency( dep )
    end

    def add_dependency(dep)
      return if @page.do_not_track_dependencies
      return if @page.output_path.nil?
      return if dep == @page
      $LOG.debug "adding dependency #{dep.source_path} to #{page.source_path}" if $LOG.debug?
      @dependencies << dep
      dep.dependencies.add_dependent( page )
    end

    def add_key_dependency(dep)
      return if @page.do_not_track_dependencies
      return if @page.output_path.nil?
      return if dep == @page
      @key_dependencies << dep
      dep.dependencies.add_key_dependent( page )
    end

    def add_dependent(dep)
      @dependents << dep
    end

    def add_key_dependent(dep)
      @key_dependents << dep
    end

    def remove_dependent(dep)
      @dependents.delete( dep )
    end

    def clear
      @dependencies.clear
      @dependents.each do |d|
        if (d.instance_of? Awestruct::Dependencies)
          d.remove_dependent( page )
        else
          d.dependencies.remove_dependent( page )
        end
      end
    end

    def persist!
      return if  page.output_path.nil? || page.output_path == ''
      file = File.join( @page.site.config.dir.to_s, '.awestruct', 'dependency-cache', page.output_path )
      $LOG.debug "store #{file}" if $LOG.debug?
      FileUtils.mkdir_p( File.dirname( file ) )
      File.open( file, 'w' ) do |file|
        file.puts "ch:#{@content_hash}"
        file.puts "kh:#{@key_hash}"
        @dependencies.collect{|e| e.relative_source_path }.uniq.each do |d|
          file.puts "c:#{d}" unless d.nil?
        end
        @key_dependencies.collect{|e| e.relative_source_path }.uniq.each do |d|
          file.puts "k:#{d}" unless d.nil?
        end
      end
    end

    def load!
      return if  page.output_path.nil? || page.output_path == ''
      file = File.join( @page.site.config.dir, '.awestruct', 'dependency-cache', page.output_path )
      $LOG.debug "load #{file}" if $LOG.debug?
      if ( File.exist?( file ) )
        File.open( file, 'r' ) do |file|
          file.each_line do |line|
            type, path = line.split(':')
            path ||= ""
            path.strip!
            if type.eql? 'c' or type.eql? 'k'
              d = find_page_by_path( path )
              unless d.nil?
                add_dependency( d ) if 'c'.eql? type
                add_key_dependency( d ) if 'k'.eql? type
              end
            else
              self.content_hash = path if 'ch'.eql? type
              self.key_hash = path if 'kh'.eql? type
            end
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
