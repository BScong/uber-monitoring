# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'grafana'
set :repo_url, 'https://github.com/BScong/uber-monitoring.git'

set :branch, 'master'
set :scm, :git
set :format, :pretty
set :log_level, :debug
set :node_env, (fetch(:node_env) || fetch(:stage))

set :linked_files, %w{python/params.py}
# Default value for default_env is {}
set :default_env, { node_env: fetch(:node_env) }

set :keep_releases, 5
set :ssh_options, { :forward_agent => true, :port=>22 }

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  task :copy_shared_files do
    on roles(:app) do
      # suppose we never copied those files
      fetch(:linked_files).each do |fname|
        if test("[ ! -f #{shared_path}/"+fname+" ]")
          upload! fname, "#{shared_path}/"+fname
        end
      end
    end
  end

  desc 'Install'
  task :install do
    on roles(:app) do
        execute "cd #{current_path}/ && docker-compose -p mnt stop && docker-compose -p mnt rm -f && docker pull grafana/grafana && docker pull influxdb && docker-compose -p mnt build"
#       execute "docker rmi python -f --no-prune && docker rmi grafana/grafana -f --no-prune && docker rmi influxdb -f --no-prune"
    end
  end

  desc 'Start application'
  task :start do
    on roles(:app) do

      execute "cd #{current_path}/ && docker-compose -p mnt up -d python influxdb grafana"
      within current_path do
        #nothing
      end
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app) do
      execute "cd #{current_path}/ && docker-compose stop"
      execute "cd #{current_path}/ && docker-compose rm"
      within current_path do
        #nothing
      end
    end
  end
  after :publishing, :start

  before :start, 'deploy:install'
  before 'deploy:check:linked_files', 'deploy:copy_shared_files'

end
