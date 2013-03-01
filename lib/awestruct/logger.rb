require 'logger'

module Awestruct
  class AwestructLoggerMultiIO
    def initialize(log_to_debug_io = false, *targets)
      @targets = targets
      @log_to_debug = log_to_debug_io
    end

    def write(*args)
      @targets.each do |target|
        if target.instance_of?(File) && @log_to_debug
          target.write(*args)
        end
        if args[0] !~/\[/ && target.instance_of?(IO)
          target.write(*args)
        end
      end
    end

    def close
      @targs.each(&:close)
    end
  end

  class AwestructLogFormatter < Logger::Formatter
    attr_accessor :level
    attr_accessor :progname

    def call(severity, timestamp, who, object)
      is_debug = $LOG.level == Logger::DEBUG
      if is_debug
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

      if severity =~ /DEBUG/
        "[%s] %5s -- %s [%s]\n" % [timestamp.strftime('%Y-%m-%d %H:%M:%S'), severity, object, who]
      else
        "%s\n" % [object]
      end
    end
  end
end
