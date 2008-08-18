desc 'Create database, copy git assets, copy views'
task :app_helpers => [ 'app_helpers:db', 'app_helpers:git' 'app_helpers:views' ]

namespace :app_helpers do
    
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
