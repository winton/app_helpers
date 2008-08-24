namespace :app_helpers do
  
  desc 'Updates views/app_helpers'
  task :views => 'app_helpers:views:to_app'
  
  namespace :views do
    desc 'Copies plugin resources to app'
    task :to_app do
      app_helper_resource :views, 'app/views/app_helpers'
    end

    desc 'Copies app resources to plugin'
    task :to_plugin do
      app_helper_resource :views, 'app/views/app_helpers', true
    end
    
    desc 'Removes plugin resources from app'
    task :remove do
      rm_rf 'app/views/app_helpers'
    end
  end

end