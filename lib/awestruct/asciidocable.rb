module Awestruct
  module AsciiDocable

    def render(context)
      imagesdir = Pathname.new('/images').relative_path_from(Pathname.new(File.dirname(context.page.relative_source_path)))
      iconsdir = File.join(imagesdir, 'icons')
      rendered = ''
      begin
        rendered = execute("asciidoc -s -b xhtml11 -a pygments -a icons -a iconsdir='#{iconsdir}' -a imagesdir='#{imagesdir}' -o - -", context.interpolate_string(raw_page_content))
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
