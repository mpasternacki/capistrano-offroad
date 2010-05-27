# My defaults for deployment, may or may nat be useful for anyone else.
require 'capistrano'

Capistrano::Configuration.instance(:must_exist).load do
  set :scm, :git
  set :ssh_options, { :forward_agent => true }
  set :use_sudo, false
  set :deploy_to, "/srv/#{application}"
end
