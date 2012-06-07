
module Awestruct
  module Rack

    class App
      def initialize(doc_root)
        @doc_root = doc_root
      end

      def call(env)
        path = env['REQUEST_PATH']
        fs_path = File.join( @doc_root, path )
        
        if ( File.directory?( fs_path ) )
          if ( ! ( path =~ %r(/$) ) )
            return [ 301,
                     { :location=>path + '/' },
                     "Redirecting to: #{path}" ]
          elsif ( File.exist?( File.join( fs_path, 'index.html' ) ) )
            fs_path = File.join( fs_path, 'index.html' )
          end
        end

        if ( File.exist?( fs_path ) )
          [ 200,
            {},
            read_content( fs_path ) ]
        else
          [ 404,
            {},
            read_error_document(path) ]
        end
      end

      def read_error_document( path )
        doc_path = nil
        htaccess = File.join( @doc_root, '.htaccess' ) 
        if ( File.exist?( htaccess ) )
          File.open( htaccess ).each_line do |line|
            if ( line =~ %r(^.*ErrorDocument[ \t]+404[ \t]+(.+)$) )
              doc_path = $1
            end
          end
        end
        if ( doc_path )
          fs_doc_path = File.join( @doc_root, doc_path )
          return read_content( fs_doc_path ) if File.exist?( fs_doc_path ) 
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
