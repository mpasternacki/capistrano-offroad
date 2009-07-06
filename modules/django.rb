# Django deployment

set :python, "python"

set :django_project_subdirectory, "project"

depend :remote, :command, "#{python}"

def django_manage(cmd, path="#{latest_release}")
  run "cd #{path}/#{django_project_subdirectory}; #{python} manage.py #{cmd}"
end

namespace :deploy do
  task :migrate do
    django_manage "syncdb"
  end
end
