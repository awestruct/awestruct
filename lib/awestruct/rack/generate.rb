
module Awestruct
  module Rack

    class GenerateOnAccess
      def initialize(app)
        @app = app
      end

      def call(env)
        engine = ::Awestruct::Engine.instance

        generate = false

        req_path = env['REQUEST_PATH']
        path = req_path
        path = req_path + 'index.html' if req_path.end_with? '/'

        page = engine.site.pages_by_output_path[path]
        if page.nil? and !req_path.end_with? '/'
          path = req_path + '/index.html'
          page = engine.site.pages_by_output_path[path]
        end

        unless page.nil?
          generate_path = File.join(engine.site.config.output_dir, page.output_path)

          generate = true if page.stale_output? generate_path
          generate = true if path.end_with? '.html'
        end

        if generate
          puts "Regenerate #{page.source_path}"

          engine.generate_page page, true
        end

        @app.call(env)
      end
    end

  end
end
