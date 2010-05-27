# Django deployment

require 'capistrano'

Capistrano::Configuration.instance(:must_exist).load do

  set :python, "python"

  set :django_project_subdirectory, "project"
  set :django_use_south, false

  depend :remote, :command, "#{python}"

  def django_manage(cmd, options={})
    path = options.delete(:path) || "#{latest_release}"
    run "cd #{path}/#{django_project_subdirectory}; #{python} manage.py #{cmd}", options
  end

  namespace :django do
    desc <<EOF
Run custom Django management command in latest release.

Pass the management command and arguments in COMMAND="..." variable.
If COMMAND variable is not provided, Capistrano will ask for a command.
EOF
    task :manage do
      set_from_env_or_ask :command, "Enter management command"
      django_manage "#{command}"
    end
  end

  namespace :deploy do
    desc "Run manage.py syncdb in latest release."
    task :migrate, :roles => :db, :only => { :primary => true } do
      # FIXME: path, see default railsy deploy:migrate
      m = if fetch(:django_use_south, false) then "--migrate" else "" end
      django_manage "syncdb --noinput #{m}"
    end
  end

  # depend :remote, :python_module, "module_name"
  # runs #{python} and tries to import module_name.
  class Capistrano::Deploy::RemoteDependency
    def python_module(module_name, options={})
      @message ||= "Cannot import `#{module_name}'"
      python = configuration.fetch(:python, "python")
      try("#{python} -c 'import #{module_name}'", options)
      self
    end
  end
end