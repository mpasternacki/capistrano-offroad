load 'reset.rb'
load 'ext.rb'
def offroad_modules(*modules)
  modules.each { |mod| load("modules/#{mod}.rb"); }
end
