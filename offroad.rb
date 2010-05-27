# Compatibility file from times when capistrano-offroad has not been
# a proper gem yet.  Do not use in new projects.  Do not look, do not touch.

warn <<EOF
WARNING: You are using offroad.rb / offroad_modules interface.
         It is obsolete and unsupported.
         Please read the README and update your project.
EOF

require 'capistrano'

$:.unshift File.join(File.dirname(__FILE__), 'lib')

def _load_relative(file)
  require "capistrano-offroad/#{file}"
end

_load_relative 'reset.rb'
_load_relative 'utils.rb'
_load_relative 'version.rb'

def offroad_modules(*modules)
  modules.each { |mod| _load_relative "modules/#{mod}.rb" }
end
