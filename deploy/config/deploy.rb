# config valid only for current version of Capistrano
lock '3.3.5'

set :rbenv_ruby, '1.9.3-p551'
set :rbenv_path, '/opt/rbenv'


set :application, "pinpoint" # EDIT THIS TO MATCH YOUR APP NAME
set :deploy_to, "/var/www/#{fetch(:application)}"

set :scm, :git

set :user, "app" # EDIT THIS TO MATCH YOUR SITE ADMIN NAME
set :use_sudo, false
#ssh_options[:forward_agent] = false # USE THIS IF YOU ARE USING SSH KEYS

set :deploy_via, :copy

set :copy_remote_dir, deploy_to

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty,  false

# Default value for keep_releases is 5
set :keep_releases, 3

set :delayed_job_server_role, :app

# files we want symlinking to specific entries in shared
set :linked_files, %w{config/database.yml config/backup/my_config.rb}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/logos}

set :whenever_environment, ->{ fetch(:rails_env) }
set :whenever_roles, ->{ :all }
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:rails_env)}" }

namespace :deploy do
  desc 'Create and upload project tarball'
  task :upload_tarball do |task, args|
    tarball_path = fetch(:project_tarball_path)
    # This will create a project tarball from HEAD, stashed and not committed changes wont be released.
   `cd ../ && git archive -o #{tarball_path} HEAD`
    raise 'Error creating tarball.'if $? != 0

    on roles(:all) do
      upload! tarball_path, tarball_path
    end
  end

  after 'deploy:publishing', 'deploy:restart'
end

namespace :delayed_job do
  def rails_env
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end

  def args
    fetch(:delayed_job_args, '')
  end

  def roles
    fetch(:delayed_job_server_role, :app)
  end

  def delayed_job_command
    fetch(:delayed_job_command, 'script/delayed_job')
  end

  desc 'Stop the delayed_job process'
  task :stop do
    on roles(roles) do
      run "cd #{current_path} && #{rails_env} #{delayed_job_command} stop #{args}"
    end
  end

  desc 'Start the delayed_job process'
  task :start do
    on roles(roles) do
      run "cd #{current_path} && #{rails_env} #{delayed_job_command} start #{args}"
    end
  end

  desc 'Restart the delayed_job process'
  task :restart do
    on roles(roles) do
      run "cd #{current_path} && #{rails_env} #{delayed_job_command} restart #{args}"
    end
  end
end

# release id is just the commit hash used to create the tarball.
set :project_release_id, `git log --pretty=format:'%h' -n 1 HEAD`
# the same path is used local and remote... just to make things simple for who wrote this.
set :project_tarball_path, "/tmp/#{fetch(:application)}-#{fetch(:project_release_id)}.tar.gz"

# Capistrano will use the module in :git_strategy property to know what to do on some Capistrano operations.
set :git_strategy, NoGitStrategy

# Attach our upload_tarball task to Capistrano deploy task chain.
before 'deploy:updating', 'deploy:upload_tarball'

after "deploy:restart", "delayed_job:restart"
