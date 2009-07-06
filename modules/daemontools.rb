# Running via demontools

set :svscan_root, "/service"
set :supervise_name, "#{application}"

def svc(cmd)
  sudo "svc #{cmd} #{svscan_root}/#{supervise_name}"
end

namespace :daemontools do
  task :create_symlink do
    sudo "ln -s -v #{current_path} #{svscan_root}/#{supervise_name}"
  end
  task :remove_symlink do
    sudo "rm -v #{svscan_root}/#{supervise_name}"
  end
  task :remove do
    remove_symlnk
    sudo "svc -x #{current_path}"
  end
end

namespace :deploy do
  task :start do
    svc "-u"
  end
  task :stop do
    svc "-d"
  end
  task :restart do
    svc "-t"
  end
  task :symlink do
    on_rollback { run "rm -f #{current_path}; ln -s #{previous_release} #{current_path}; true" } # FIXME!
    run "rm -f #{current_path}"
    sleep 5
    sudo "svc -t -x #{previous_release}"
    run "ln -s #{latest_release} #{current_path}"
  end
end
