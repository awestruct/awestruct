
module Awestruct
  module Rack

    class App
      def initialize(doc_root)
        @doc_root = doc_root
      end

      def call(env)
        path = env['PATH_INFO']
        fs_path = File.join( @doc_root, path )

        if ( File.directory?( fs_path ) )
          if ( ! ( path =~ %r(/$) ) )
            return [ 301,
                     { 'location'=>File.join(path, '') },
                     ["Redirecting to: #{path}"] ]
          elsif ( File.file?( File.join( fs_path, 'index.html' ) ) )
            fs_path = File.join( fs_path, 'index.html' )
          end
        end

        # There must be a Content-Type, except when the Status is 1xx,
        # 204 or 304, in which case there must be none given.
        #
        # The Body must respond to each and must only yield String
        # values. The Body itself should not be an instance of String,
        # as this will break in Ruby 1.9.
        if ( File.file?( fs_path ) )
          body = read_content( fs_path )
          content_type = ::Rack::Mime.mime_type( File.extname(fs_path) )
          length = body.size.to_s
          [ 200,
            {"Content-Type" => content_type, "Content-Length" => length},
            [body] ]
        else
          body, content_type = read_error_document(path)
          length = body.size.to_s
          [ 404,
            {"Content-Type" => content_type || 'text/plain', "Content-Length" => length},
            [body] ]
        end
      end

      def read_error_document( path )
        doc_path = nil
        htaccess = File.join( @doc_root, '.htaccess' )
        if ( File.file?( htaccess ) )
          File.open( htaccess ).each_line do |line|
            if ( line =~ %r(^.*ErrorDocument[ \t]+404[ \t]+(.+)$) )
              doc_path = $1
            end
          end
        end
        if ( doc_path )
          fs_doc_path = File.join( @doc_root, doc_path )
          return [read_content( fs_doc_path ), ::Rack::Mime.mime_type( File.extname(fs_doc_path) )] if File.file?( fs_doc_path )
        end
        "404: Not Found: #{path}"
      end


      def read_content( path )
        input_stream = IO.open(IO.sysopen(path, "rb"), "rb" )
        result = input_stream.read
        return result
      ensure
        input_stream.close
      end
    end

  end
end
