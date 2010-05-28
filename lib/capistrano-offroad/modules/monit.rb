require 'capistrano'

Capistrano::Configuration.instance(:must_exist).load do
  set :monit_group, nil         # process group to start/stop/reload
  set :monit_command, "monit"

  def _monit_args()
    if fetch :monit_group, nil then
      return " -g #{monit_group} "
    else
      return ""
    end
  end

  namespace :deploy do
    desc "Start processes"
    task :start do
      process = ENV['PROCESS'] || 'all'
      sudo "#{monit_command} #{_monit_args} start #{process}"
    end

    desc "Stop processes"
    task :stop do
      process = ENV['PROCESS'] || 'all'
      sudo "#{monit_command} #{_monit_args} stop #{process}"
    end

    desc "Restart processes"
    task :restart do
      process = ENV['PROCESS'] || 'all'
      sudo "#{monit_command} #{_monit_args} restart #{process}"
    end

    namespace :status do
      desc "Status summary"
      task :default do
        sudo "#{monit_command} #{_monit_args} summary"
      end

      desc "Full status"
      task :full do
        sudo "#{monit_command} #{_monit_args} status"
      end
    end

    desc "Reload monit"
    task :reload_monit do
      sudo "#{monit_command} reload"
    end
  end
end
