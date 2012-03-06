module Awestruct
  module ReStructuredTextable

    def render(context)
      hl = 1
      if front_matter['initial_header_level'].to_s =~ /^[1-6]$/
        hl = front_matter['initial_header_level']
      end
      rendered = ''
      begin
        doc = execute( "rst2html --strip-comments --no-doc-title --initial-header-level=#{hl}", context.interpolate_string( raw_page_content ) )
        rendered = Hpricot( doc ).at( '/html/body/div[@class="document"]' ).inner_html.strip
      rescue => e
        puts e
        puts e.backtrace
      end
      rendered
    end

    def content
      context = site.engine.create_context( self )
      render( context )
    end

    def execute(command, target)
      out = ''
      Open3.popen3(command) do |stdin, stdout, _|
        stdin.puts target
        stdin.close
        out = stdout.read
      end
      out.gsub("\r", '')
    rescue Errno::EPIPE
      ""
    end

  end
end
