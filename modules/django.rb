# Django deployment

set :python, "python"

set :django_project_subdirectory, "project"

depend :remote, :command, "#{python}"

def django_manage(cmd, path="#{latest_release}")
  run "cd #{path}/#{django_project_subdirectory}; #{python} manage.py #{cmd}"
end

namespace :django do
  desc "Run manage.py syncdb in latest release."
  task :syncdb do
    django_manage "syncdb"
  end

  desc "Run custom Django management command in latest release."
  task :manage do
    set_from_env_or_ask :command, "Enter management command"
    django_manage "#{command}"
  end
end

after "deploy:update", "django:syncdb"

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
