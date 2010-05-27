require 'capistrano-offroad/version'
require 'capistrano-offroad/reset'
require 'capistrano-offroad/utils'

# just for consistency
def offroad_modules(*modules)
  modules.each { |mod| require "capistrano-offroad/modules/#{mod}" }
end
