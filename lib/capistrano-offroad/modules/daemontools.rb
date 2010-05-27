# Running via demontools
require 'capistrano'

Capistrano::Configuration.instance(:must_exist).load do
  set :svscan_root, "/service"
  set :supervise_name, "#{application}"

  def svc(cmd)
    sudo "svc #{cmd} #{svscan_root}/#{supervise_name}"
  end

  namespace :daemontools do
    desc "Create symlink in svscan directory"
    task :create_symlink do
      sudo "ln -s -v #{current_path} #{svscan_root}/#{supervise_name}"
    end

    desc "[internal] Remove symlink from svscan directory"
    task :remove_symlink do
      sudo "rm -v #{svscan_root}/#{supervise_name}"
    end

    desc "Remove symlink from svscan directory and stop supervise"
    task :remove do
      remove_symlink
      sudo "svc -x -t #{current_path}"
    end

    desc "Supervise status of current release"
    task :status do
      sudo "svstat #{svscan_root}/#{supervise_name}"
    end

    desc "Supervise status of all releases"
    task :relstatus do
      sudo "svstat #{releases_path}/*"
    end
  end

  namespace :deploy do
    desc "Start service (svc -u)"
    task :start do
      svc "-u"
    end

    desc "Stop service (svc -d)"
    task :stop do
      svc "-d"
    end

    desc "Restart service (svc -t)"
    task :restart do
      svc "-t"
    end

    desc <<-DESC
  [internal] Symlink latest release to current, taking daemontools into accont.

  WARNING: rollback is broken!
  DESC
    task :symlink do
      on_rollback { run "rm -f #{current_path}; ln -s #{previous_release} #{current_path}; true" } # FIXME!
      run "rm -f #{current_path}"
      sleep 5
      sudo "svc -t -x #{previous_release}"
      run "ln -s #{latest_release} #{current_path}"
    end
  end

  before "deploy:cleanup" do
    # needed, by default I don't use sudo, but we need one to remove
    # supervise/ directories.
    set :run_method, :sudo
  end
end
