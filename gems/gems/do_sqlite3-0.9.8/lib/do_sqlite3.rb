
# HACK: If running on Windows, then add the current directory to the PATH
# for the current process so it can find the bundled dlls before the require
# of the actual extension file.
if RUBY_PLATFORM.match(/mingw|mswin/i)
  libdir = File.expand_path(File.dirname(__FILE__)).gsub(File::SEPARATOR, File::ALT_SEPARATOR)
  ENV['PATH'] = File.join(libdir, "do_sqlite3;") + ENV['PATH']
end

require 'rubygems'
require 'data_objects'
require File.expand_path(File.join(File.dirname(__FILE__), 'do_sqlite3_ext.bundle'))
require File.expand_path(File.join(File.dirname(__FILE__), 'do_sqlite3', 'transaction'))
