# Reset Rails-specific stuff.

require 'capistrano'

Capistrano::Configuration.instance(:must_exist).load do
  set :shared_children, %w()

  namespace :deploy do
    task :finalize_update, :except => { :no_release => true } do
      if fetch(:group_writable, true)
        if :no_chgrp == fetch(:group_writable, true)
          # skip step
        elsif :sudo_chgrp == fetch(:group_writable, true)
          sudo "chgrp -R #{deploy_group} #{latest_release}"
        else
          run "chgrp -R #{deploy_group} #{latest_release}"
        end
        run "chmod -R g+w #{latest_release}"
      end
    end
    task :migrate do end
    task :start do end
    task :stop do end
    task :restart do end
  end
end
