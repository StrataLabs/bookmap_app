require 'bundler/capistrano'

set :application, "bookmap"
set :repository,  "git://github.com/StrataLabs/bookmap_app.git"
set :deploy_via, :remote_cache
set :scm, :git


set :scm_username, 'akil_rails'
set :use_sudo, false
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")] 

def legacy_production name
  task name do
    set :branch, "master"
    set :default_environment, {  "LD_LIBRARY_PATH" => "/opt/oracle/instantclient_10_2", "TNS_ADMIN" => "/opt/oracle/network/admin" }
    role :web, "74.86.131.195"                          # Your HTTP server, Apache/etc
    role :app, "74.86.131.195"                          # This may be the same as your `Web` server
    role :db,  "74.86.131.195", :primary => true        # This is where Rails migrations will run
    set :user, 'rails'
    yield
  end
end

def aws name
  task name, :on_error => :continue do
    set :branch, "master"
    set :default_environment, { "PATH" => "/rails/common/ruby-1.9.2-p290/bin:$PATH", "LD_LIBRARY_PATH" => "/rails/common/oracle/instantclient_11_2", "TNS_ADMIN" => "/rails/common/oracle/network/admin" }
    role :web, "107.21.238.175"                          # Your HTTP server, Apache/etc
    role :app, "107.21.238.175"                          # This may be the same as your `Web` server
    role :db,  "107.21.238.175", :primary => true        # This is where Rails migrations will run
    set :user, 'rails'
    yield
  end
end

aws :ec2_production do
  set :deploy_to, "/rails/apps/bookmap"
end

legacy_production :production do
  set :deploy_to, "/disk1/bookmap"
end

# after "deploy", "deploy:migrate"

namespace :deploy do
  # after "deploy:update_code" do
  #   run "cp #{deploy_to}/database.yml #{release_path}/config/database.yml"
  # end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

