set :supervisord_path, ""
set :supervisord_command, "supervisord"
set :supervisorctl_command, "supervisorctl"
set :supervisord_conf, "supervisord_conf"
set :supervisord_pidfile, "supervisord.pid"
set :supervisord_start_group, nil
set :supervisord_stop_group, nil

namespace :deploy do
  def supervisord_pidfile_path ; "#{shared_path}/#{supervisord_pidfile}" end
  def supervisord_pid ; "`cat #{supervisord_pidfile_path}`" end

  # Run supervisorctl command `cmd'.
  # If options[:try_start] is true (default) and supervisord is not running, start it.
  # If just started supervisord, and options[:run_when_started] is false (default), skip running supervisorctl
  def supervisorctl(cmd, options={})
    try_start = options.delete(:try_start) {|k| true}

    full_command = "#{supervisord_path}#{supervisorctl_command} -c #{current_path}/#{supervisord_conf} #{cmd}"
    after_start = (full_command if options.delete(:run_when_started)) || ""

    if not try_start then
      run full_command, options
    else
      run <<-EOF, options
        if test -f #{shared_path}/#{supervisord_pidfile}
             && ps #{supervisord_pid} > /dev/null ;
        then
          echo "supervisord seems to be up, good" ;
          #{full_command} ;
        else
          echo "starting supervisord" ;
          #{sudo :as => deploy_user} #{supervisord_path}#{supervisord_command} -c #{current_path}/#{supervisord_conf} ;
          #{after_start}
        fi
    EOF
    end
  end

  def _target(var)
    group_name = ENV['GROUP']
    group_name ||= fetch var
    prog_name = ENV['PROGRAM']
    prog_name ||= 'all'

    if ['', nil].include? group_name then
      prog_name
    else
      "'#{group_name}:*'"
    end
  end

  desc "Start processes"
  task :start do
    to_start = _target(:supervisord_start_group)
    supervisorctl "start #{to_start}", :try_start => true
  end

  desc "Stop processes"
  task :stop do
    to_stop = _target(:supervisord_stop_group)
    supervisorctl "stop #{to_stop}", :try_start => false
  end

  desc "Restart processes"
  task :restart do
    to_restart = _target(:supervisord_start_group)
    supervisorctl "restart #{to_restart}"
  end

  desc "Display status of processes"
  task :status do
    supervisorctl "status", :try_start => false
  end

  desc "Display detailed list of processes"
  task :processes do
    run "test -f #{supervisord_pidfile_path} && pstree -a #{supervisord_pid}"
  end

  desc "Reload supervisor daemon"
  task :reload_supervisord do
    supervisorctl "reload"
  end

  task :run_supervisorctl do
    set_from_env_or_ask :command, "supervisorctl command: "
    supervisorctl "#{command}", :try_start => false
  end
end
