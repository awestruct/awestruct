require 'open-uri'
require 'restclient'

module Awestruct
  module Extensions
    module RemotePartial

      def remotePartial(url)
        url_tmp = url.sub('http://', '')
        r = 'remote_partial/' + url_tmp[/(.*)\/[^\/].+$/, 1]
        tmp = File.join(tmp(site.tmp_dir, r), File.basename(url_tmp))
        get_or_cache(tmp, url)
      end

      def get_or_cache(tmp_file, url)
        response_body = ""
        if !File.exist?tmp_file
          puts url
          response_body = RestClient.get(url, :cache => false) { |response, request, result, &block|
            case response.code
            when 404
                response
            else
              response.return!(request, result, &block)
            end
          }.body;
          File.open(tmp_file, 'w') do |out|
            out.write response_body
          end
        else
          response_body = File.read(tmp_file)
        end
        return response_body
      end


    end
  end
end
