# Put this init script directly into the Alfred script window and
# it will load main.rb with console logging enabled for Ruby exceptions

Encoding::default_external = Encoding::UTF_8 if defined? Encoding

ENV['GEM_PATH'] = File.join(Dir.pwd, 'rubygems')

# Provide a facility to log messages to Console.app:
def console_log(msg)
  escape = proc{ |m| m.gsub("'", "'\\\\''") }
  `logger -t 'Alfred Workflow' '#{escape[msg]}'`
end
# Yay! A way to debug Alfred scripts. You can use either method:
#   raise "I need to explain how this happened…"
#                   OR
#   Alfred.log "parachutes away!"
#
# To see the messages, open up Console.app


def load_ruby_file(filename)
  ruby_code = IO.read(filename)
  eval(ruby_code, binding, File.expand_path(filename))
end


begin
  # Load the Alfred singleton object
  load_ruby_file("alfred.rb")
  Alfred = AlfredInit.new("{query}")

  # Load your code from main.rb:
  load_ruby_file("main.rb")
rescue Exception => e
  slice = -1
  # Ignore final 2 lines of backtrace that always come from this file
  slice = -3 if e.backtrace.size > 2
  bt = e.backtrace[0..slice].join("\n  ")
  console_log "#{e.message} (#{e.class}) [query: {query}]\n  " + bt
end
