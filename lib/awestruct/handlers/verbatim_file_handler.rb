require 'awestruct/handlers/file_handler'

module Awestruct
  module Handlers
    class VerbatimFileHandler < FileHandler
      # Read file in binary mode so that it can be copied to the generated site as is
      def read_content
        File.open(@path, 'rb') {|is| is.read }
      end
    end
  end
end
