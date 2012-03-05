module Awestruct
  module AsciiDocable

    def render(context)
      _render(context.interpolate_string(raw_page_content), context.page.relative_source_path, site)
    end

    def content
      context = site.engine.create_context( self )
      render( context )
    end

    def _render(content, relative_source_path, site)
      # TODO replace with site.engine.config.images_dir once available
      imagesdir = Pathname.new('/images').relative_path_from(Pathname.new(File.dirname(relative_source_path)))
      iconsdir = File.join(imagesdir, 'icons')
      conffile = File.join(site.engine.config.config_dir, 'asciidoc.conf')
      confopt = File.exist?(conffile) ? '-f ' + conffile : ''
      rendered = ''
      begin
        rendered = execute("asciidoc -s -b html5 -a pygments -a icons -a iconsdir='#{iconsdir}' -a imagesdir='#{imagesdir}' #{confopt} -o - -", content)
      rescue => e
        puts e
        puts e.backtrace
      end
      rendered
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
