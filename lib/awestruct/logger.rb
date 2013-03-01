require 'logger'

module Awestruct
  class AwestructLogFormatter < Logger::Formatter
    attr_accessor :level
    attr_accessor :progname

    def call(severity, timestamp, who, object)
      # override progname to be the caller if the log level threshold is DEBUG
      # We only do this if the logger level is DEBUG because inspecting the
      # stack and doing extra string manipulation can have performance impacts
      # under high logging rates.
      if $LOG.level == Logger::DEBUG
        # callstack inspection, include our caller
        # turn this: "/usr/lib/ruby/1.8/irb/workspace.rb:52:in `irb_binding'"
        # into this: ["/usr/lib/ruby/1.8/irb/workspace.rb", "52", "irb_binding"]
        #
        # caller[3] is actually who invoked the Logger#<type>
        # This only works if you use the severity methods
        path, line, method = caller[3].split(/(?::in `|:|')/)
        # Trim RUBYLIB path from 'file' if we can
        #whence = $:.select { |p| path.start_with?(p) }[0]
        whence = $:.detect { |p| path.start_with?(p) }
        if !whence
          # We get here if the path is not in $:
          file = path
        else
          file = path[whence.length + 1..-1]
        end
        who = "#{file}:#{line}##{method}"
      end

      "[%s#] %5s -- %s [%s]\n" % [timestamp, severity, object, who]
    end
  end
end
