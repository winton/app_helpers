namespace :db do
  task :config => 'app_helpers:db:config'
end

namespace :app_helpers do
  
  desc 'Runs db:config and creates database'
  task :db => [ 'app_helpers:db:config', 'db:create' ]
  
  namespace :db do
    desc 'Creates a generic database.yml file'
    task :config do
      return if ENV['db'] == 'false'
      puts('Database name?') unless ENV['db']
      File.open 'config/database.yml', 'w' do |file|
        file.write "development: &defaults
  adapter: mysql
  database: #{ENV['db'] || STDIN.gets.strip}
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
    
    desc 'Removes database.yml'
    task :remove do
      `rm config/database.yml`
    end
  end
end