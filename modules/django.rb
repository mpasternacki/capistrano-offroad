# Django deployment

set :python, "python"

set :django_project_subdirectory, "project"

depend :remote, :command, "#{python}"

def django_manage(cmd, path="#{latest_release}")
  run "cd #{path}/#{django_project_subdirectory}; #{python} manage.py #{cmd}"
end

namespace :django do
  task :syncdb do
    django_manage "syncdb"
  end
  task :manage do
    set_from_env_or_ask :command, "Enter management command"
    django_manage "#{command}"
  end
end

after "deploy:update", "django:syncdb"
