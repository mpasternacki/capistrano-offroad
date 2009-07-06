# Running via demontools

set :svscan_root, "/service"

def svc(cmd)
  sudo "svc #{cmd} #{svscan_root}/#{application}"
end

namespace :deploy do
  task :start do
    svc "-u"
  end
  task :stop do
    svc "-d"
  end
  task :restart do
    svc ""
  end
end
