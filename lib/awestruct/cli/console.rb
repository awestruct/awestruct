require 'awestruct/engine'

module Awestruct
  module CLI
    class Console

      def run()

        puts "Query Console ready.."
        print "$> "
        STDOUT.flush
        begin
          while(input = STDIN.gets)
            begin
              execute( input )
            rescue => e
              puts e
              puts e.backtrace
            end
          end
        rescue SystemExit, Interrupt
          exit
        end

      end

      def get_pages
        Awestruct::Engine.instance.site.pages
      end

      def execute(query_expression, out = STDOUT)
        return if query_expression.strip.empty?
        query = Query.new( query_expression )

        if(query.page.source.eql? 'site')
          query.run( out, Awestruct::Engine.instance.site )
        else
          query.run( out, *get_pages )
        end

        out.puts
        out.print "$> "
        out.flush
      end
    end

    class Query
      attr_reader :page
      attr_reader :field
      attr_reader :field_full_value
      attr_reader :deps

      def initialize( expression )
        types = expression.split(":")
        page = types[0].strip
        if types.size > 1
          if "<>".include? types[1].strip
            @deps = types[1].strip
          else
            field = types[1].strip
          end
        end
        if types.size > 2
          @deps = types[1]
        end

        if field =~ /!$/
          @field_full_value = true
          field.chop!
        else
          @field_full_value = false
        end

        @page = Regexp.new page.gsub( "*", ".*" )
        @field = Regexp.new field.gsub( "*", ".*" ) unless field.nil?
      end

      def run(out, *pages)
        out.puts "Query for Page[#{@page.source}] with Field[#{@field.source unless @field.nil?}] and Dependencies[#{@deps}]"
        out.puts "----------------------------------------------------------------------------------------------------------"
        pages.each do |p|
          if @page.source.eql? 'site' or p.output_path =~ @page
            out.puts "#{p.output_path}"

            unless @field.nil?
              p.keys.each do |f|
                out.puts "\t #{f} -> #{format_field(p[f], @field_full_value)}" if f.to_s =~ @field
              end
            end

            unless @deps.nil?
              if @deps.eql? ">"
                if @field.nil?
                  p.dependencies.dependencies.each do |d|
                    out.puts "\t > #{d.output_path}"
                  end
                end
              elsif @deps.eql? "<"
                if @field.nil?
                  p.dependencies.dependents.each do |d|
                    out.puts "\t < #{d.output_path}"
                  end
                end
              end
            end
          end
        end
      end

      def format_field(field, field_full_value)
        return field.inspect if field_full_value

        val = field.inspect[0..80]
        if val.size >= 80
          val = val + "..."
        end
        return val
      end
    end

  end
end
