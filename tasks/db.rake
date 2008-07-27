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