require 'capistrano'

def _load_relative(file)
  load(File.join(File.dirname(__FILE__), file))
end

_load_relative 'reset.rb'
_load_relative 'ext.rb'

def offroad_modules(*modules)
  modules.each { |mod| _load_relative "modules/#{mod}.rb" }
end
