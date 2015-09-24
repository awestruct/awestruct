require 'awestruct/page'
require 'json'
require 'rack'

module Awestruct
  module Rack

    class Debug
      def initialize(app)
        @app = app
      end

      def call(env)
        engine = ::Awestruct::Engine.instance

        debug = false

        query = ::Rack::Utils.parse_query(env['QUERY_STRING'])
        path = env['REQUEST_PATH']
        path = path + "index.html" if path.end_with? '/'

        page = engine.site.pages_by_output_path[path]

        debug = true if !page.nil? and query.include? 'debug'

        if debug
          debug_exp = []
          debug_exp = query['debug'].split('.').reverse unless query['debug'].nil?

          if debug_exp.size == 0
            html = IO.read(File.join(File.dirname(__FILE__), "trace.html"))

            return [200,
              {"Content-Type" => "text/html", "Content-Length" => html.size},
              [html] ]

          else

            json = ''
            begin
              json = dump(introspect(page, {}, debug_exp))

            rescue Exception => e
              json += e.message
            end

            return [200,
            {"Content-Type" => "application/json", "Content-Length" => json.size},
            [json] ]
          end

        else
          source_call = @app.call(env)
          if source_call[1]["Content-Type"].eql? "text/html"
            html = source_call[2][0]
            html += %Q(
              <script>
                document.addEventListener("keypress", function(event) {
                    if(event.shiftKey && event.keyCode == 63) {
                        window.open(window.location.pathname + '?debug', '_blank')
                    }
                });
              </script>
            )
            source_call[1]["Content-Length"] = html.size
            source_call[2][0] = html
          end

          return source_call
        end

      end

      def introspect(source, target, exp, depth = 0)
        #puts "#{source.class} -> #{target.class} -> #{exp.join(':')}"
        return target if source.nil?

        exp_all_curr = exp.clone
        exp_curr = exp_all_curr.pop

        if source.is_a? Array
          if !exp_curr.nil? and exp_curr[/^-?\d+$/]
            #puts "Going for simple array index"
            target_arr = []
            (0...source.size).each {|x| target_arr[x] = {}}
            target_arr[exp_curr.to_i] = introspect(source[exp_curr.to_i], {}, exp_all_curr, depth+1)
            return target_arr
          else
            #puts "Non index lookup"
            target_arr = []
            source.each{ |var| target_arr << introspect(var, {}, exp, depth+1)}
            return target_arr
          end
        end

        return target if exp_curr.nil?

        data = nil

        if source.is_a? Awestruct::Page
          data = source.original_entries
        elsif source.is_a? Hash
          data = source
        elsif source.is_a? OpenStruct
          data = source.to_h
        end

        return source.to_s if data.nil?

        data.each do |key, value|

          #puts "#{key}(#{key.class}) -> #{value.class}, #{exp_curr}"

          if key.to_s == exp_curr or exp_curr == '*'
            if value.is_a? Hash or value.is_a? OpenStruct or value.is_a? Awestruct::Page
              target[key] = introspect(value, {}, exp_all_curr, depth+1)
            elsif value.is_a? Array
              #puts "Going for simple array index?"
              target[key] = introspect(value, {}, exp_all_curr, depth+1)
            else
              #puts "Value is not Hash|OpenStruct|Page #{key}"
              target[key] = value
            end
          elsif exp_curr[/^-?\d+$/]
            if value.is_a? Array
              #puts "Going for simple array index"
              target_arr = []
              target_arr << introspect(value[exp_curr.to_i], {}, exp_all_curr, depth+1)
              target[key] = target_arr
            end
          end

        end
        return target
      end

      def dump(value)
        value = value.to_h if value.is_a? OpenStruct
        JSON.pretty_generate(value)
      end
    end

  end
end
