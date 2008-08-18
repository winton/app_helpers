namespace :app_helpers do
  desc 'Updates app/widgets assets'
  task :widgets => [ 'app_helpers:widgets:javascripts:to_app', 'app_helpers:widgets:stylesheets:to_app' ]

  namespace :widgets do    
    desc 'Updates app/widgets/javascripts'
    task :javascripts do
    
      desc 'Copies plugin resources to app'
      task :to_app do
        app_helpers_resource 'widgets/javascripts', 'app/widgets/javascripts'
      end

      desc 'Copies app resources to plugin'
      task :to_plugin do
        app_helpers_resource 'widgets/javascripts', 'app/widgets/javascripts', true
      end
    
    end
  
    desc 'Updates app/widgets/stylesheets'
    task :stylesheets do
    
      desc 'Copies plugin resources to app'
      task :to_app do
        app_helpers_resource 'widgets/stylesheets', 'app/widgets/stylesheets'
      end

      desc 'Copies app resources to plugin'
      task :to_plugin do
        app_helpers_resource 'widgets/stylesheets', 'app/widgets/stylesheets', true
      end
    
    end
  end
end