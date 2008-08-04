desc 'Copy all app_helpers assets'
task :app_helpers => [ 'app_helpers:views' ]

namespace :app_helpers do
  desc 'Updates views/app_helpers'
  task :views do
    app_helper_resource :views, 'app/views/app_helpers'
  end
  
  desc 'Updates plugin resources from app'
  task :to_plugin do
    app_helper_resource 'widgets/javascripts', 'app/widgets/javascripts', true
    app_helper_resource 'widgets/stylesheets', 'app/widgets/stylesheets', true
    app_helper_resource :views, 'app/views/app_helpers', true
  end
    
  def app_helper_resource(type, to, reverse=false)
    from = "#{File.dirname(__FILE__)}/../resources/#{type}"
    from, to = to, from if reverse
    puts "=> Removing old #{type}..."
    FileUtils.remove_dir to, true
    FileUtils.mkdir_p to
    puts "=> Copying #{type}..."
    Dir["#{from}/*"].each do |f|
      if File.directory? f
        FileUtils.mkdir_p "#{to}/#{File.basename(f)}"
        FileUtils.cp_r f, to
      else
        FileUtils.cp f, to
      end
    end
  end
end
