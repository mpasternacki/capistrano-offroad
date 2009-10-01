# Django deployment

set :python, "python"

set :django_project_subdirectory, "project"
set :django_use_south, false

depend :remote, :command, "#{python}"

def django_manage(cmd, options={})
  path = options.delete(:path) || "#{latest_release}"
  run "cd #{path}/#{django_project_subdirectory}; #{python} manage.py #{cmd}"
end

namespace :django do
  desc "Run custom Django management command in latest release."
  task :manage do
    set_from_env_or_ask :command, "Enter management command"
    django_manage "#{command}"
  end
end

namespace :deploy do
  desc "Run manage.py syncdb in latest release."
  task :migrate, :roles => :db, :only => { :primary => true } do
    # FIXME: path, see default railsy deploy:migrate
    django_manage "syncdb --noinput"
    django_manage "migrate" if fetch(:django_use_south, false)
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
