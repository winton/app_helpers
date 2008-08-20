namespace :db do
  task :config => 'app_helpers:db:config'
end

namespace :app_helpers do
  
  desc 'Runs db:config and creates database'
  task :db => [ 'app_helpers:db:config', 'db:create' ]
  
  namespace :db do
    desc 'Creates a generic database.yml file'
    task :config do
      puts('Database name?') unless ENV["DB"]
      File.open 'config/database.yml', 'w' do |file|
        file.write "development: &defaults
  adapter: mysql
  database: #{ENV["DB"] || STDIN.gets.strip}
  username: root
  password: 
  host: localhost

test:
  <<: *defaults

production:
  <<: *defaults
"
      end
    end
  end
end