# During the client run we remove all traces of the chef-zero run, eg: /tmp
# The client does a node.save it attempts to write out the node json to /tmp
# which no longer exists.  It then writes out a stacktrace.out.
# This is a hack so we don't write the stacktrace.out to disk
class Chef
  # Hackity Hack, don't talk back
  class Application
    class << self
      def debug_stacktrace(e)
        message = "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
        chef_stacktrace_out = "Generated at #{Time.now}\n"
        chef_stacktrace_out << message

        # Chef::FileCache.store("chef-stacktrace.out", chef_stacktrace_out)
        # Chef::Log.fatal("Stacktrace dumped to #{Chef::FileCache.load("chef-stacktrace.out", false)}")
        Chef::Log.debug(message)
        true
      end
    end
  end
end
