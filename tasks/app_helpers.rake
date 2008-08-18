desc 'Copy database config, git assets, views, widget assets'
task :app_helpers => [ 'app_helpers:db', 'app_helpers:git', 'app_helpers:views', 'app_helpers:widgets' ]

namespace :app_helpers do
    
  def app_helper_resource(type, to, reverse=false)
    from = "#{File.dirname(__FILE__)}/../resources/#{type}"
    from, to = to, from if reverse
    puts "=> Removing old #{type}..."
    if File.directory?(to)
      FileUtils.remove_dir to, true
      FileUtils.mkdir_p to
    else
      File.unlink to
    end if File.exists?(to)
    puts "=> Copying #{type}..."
    (File.directory?(from) ? Dir["#{from}/*"] : [from]).each do |f|
      if File.directory? f
        FileUtils.mkdir_p "#{to}/#{File.basename(f)}"
        FileUtils.cp_r f, to
      else
        FileUtils.cp f, to
      end
    end if File.exists?(from)
  end
  
end
