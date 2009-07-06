# Reset Rails-specific stuff.

set :shared_children, %w()

namespace :deploy do
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
  end
  task :migrate do end
  task :start do end
  task :stop do end
  task :restart do end
end
