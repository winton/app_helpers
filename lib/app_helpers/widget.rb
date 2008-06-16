module AppHelpers
  
  class Widget
    attr :assets,  true
    attr :lineage, true
    attr :options, true
    attr :logger,  true
    
    def initialize(controller, *lineage)
      @controller = controller
      @logger     = []
      
      @options = lineage.extract_options!
      @lineage = lineage
      return  if lineage.empty?
      
      @assets  = { :javascripts => [], :stylesheets => [], :templates => [] }
      @options = merged_options.merge @options
      
      update_assets :javascripts
      update_assets :stylesheets
    end
    
    private
    
    def merged_options(index=0, options={})
      return if index >= @lineage.length
      path = to_string :options, index
      options.merge!(eval(File.read(path))) if File.exists?(path)
      merged_options index+1, options
      options
    end
    
    def needs_update?(from, to)
      File.exists?(to) ? File.mtime(from) > File.mtime(to) : true
    end
    
    def to_string(type, index=@lineage.length-1)
      lineage = @lineage[0..index]
      asset   = [ @lineage.join('_'), lineage.join('/') ].join '/'
      base    = 'app/widgets/' + lineage.join('/widgets/')
      case type
      when :base:          base
      when :asset:         asset
      when :options:       base + '/options.rb'
      when :javascripts: [ base + '/javascripts', 'public/javascripts/widgets/' + asset ]
      when :stylesheets: [ base + '/stylesheets', 'public/stylesheets/widgets/' + asset ]
      end
    end
    
    def update_assets(type, index=0)
      return if index >= @lineage.length
      @assets[type] += update_directory(*to_string(type, index), index))
      update_assets(type, index + 1)
    end
    
    def update_directory(from, to, index)
      Dir["#{from}/*"].collect do |f|
        t = to + f[from.length..-1]
        t.gsub!('/widgets/', '/sass/widgets/') if f.include?('.sass')
        update_directory(f, t, index) and next if File.directory?(f)
        if needs_update?(f, t)
          @logger << 'CREATE ' + t.inspect
          @logger << 'FROM   ' + f.inspect
          FileUtils.mkdir_p File.dirname(t)
          File.open t, 'w' do |file|
            file.write @controller.render_to_string(:file => f, :locals => @options)
          end
        end
        [ 'widgets', to_string(:asset, index), File.basename(t).split('.')[0] ].join '/'
      end
    end
  end
  
  ##########
  
  def widget(*lineage)
    w = Widget.new(controller, *lineage)
    [w.assets.inspect, w.lineage.inspect, w.options.inspect, w.logger.join("<br/>")].join "<br/><br/>"
  end
  
  def widget2(*args)
    options = args.extract_options!
    return if args.empty?
    
    js   = []
    css  = []
    sass = []
    init = []
    
    while args.length > 0
      path    = args.join('/widgets/')
      paths   = widget_paths path
      options = options.merge eval(File.read(paths[:def]))
      
      js   << update_directory(paths, options, :js)
      css  << update_directory(paths, options, :css)
      sass << update_directory(paths, options, :sass)
      
      # Update templates
      Dir["#{paths[:jst]}/*"].each do |file|
        base = File.basename(file).split('.')[0][1..-1]
        id   = [ paths[:asset].split('/'), base ].flatten.join('_')
        file = "#{path}/templates/#{base}"
        templates [ id, file, options ]
      end
      
      # Init partials
      Dir["#{paths[:html]}/_init.*"].each do |file|
        base = File.basename(file).split('.')[0][1..-1]
        init << render_to_string(:partial => "#{path}/partials/#{base}", :locals => options)
      end
      
      args.pop
    end
    
    # See assets.rb
    javascripts *js.reverse.flatten
    stylesheets *(css.reverse.flatten + sass.reverse.flatten)
    
    init.join "\n"
  end
  
  def widget_partial(*args)
    path = args.join('/widgets/') + "/templates/#{args.pop}"
  end

private
  
  def needs_update?(from, to)
    File.exists?(to) ? File.mtime(from) > File.mtime(to) : true
  end
  
  def options_binding(options)
    evals = ''
    pairs = options.to_a
    pairs.each_index { |i| evals += "#{pairs[i][0]} = pairs[#{i}][1];" }
    eval evals
    binding
  end
  
  def update_directory(paths, options, type)
    path_from = paths[type]
    path_to   = paths[:copy_to][type]
    
    erb  = Dir["#{path_from}/*.#{type}.erb"].collect
    from = Dir["#{path_from}/*.#{type}"].collect
    to   = Dir["#{path_to}/*.#{type}"  ].collect
    
    base_erb  = erb.collect  { |f| File.basename f, '.erb' }
    base_from = from.collect { |f| File.basename f }
    base_to   = to.collect   { |f| File.basename f }
    
    # Delete files removed from widget
    (base_to - base_from - base_erb).each do |f|
      File.delete [ path_to, f ].join('/')
    end
    
    # Copy non-ERB files
    assets = from.collect do |f|
      t = [ path_to, File.basename(f) ].join '/'
      if needs_update?(f, t)
        system "mkdir -p #{File.dirname t}"
        system "cp -f #{f} #{t}"
      end
      [ 'widgets', paths[:asset], File.basename(f, ".#{type}") ].join '/'
    end
    
    # Copy ERB files
    assets + erb.collect do |f|
      t = [ path_to, File.basename(f, '.erb') ].join '/'
      if needs_update?(f, t)
        system "mkdir -p #{File.dirname t}"
        File.open t, 'w' do |file|
          file.write ERB.new(File.read(f)).result(options_binding(options))
        end
      end
      [ 'widgets', paths[:asset], File.basename(f, ".#{type}.erb") ].join '/'
    end
  end

  def widget_paths(path)
    base  = "app/widgets/#{path}"
    asset = "#{path.gsub '/widgets', ''}"
    {
      :def   => "#{base}/options.rb",
      :js    => "#{base}/javascripts",
      :jst   => "#{base}/templates",
      :css   => "#{base}/stylesheets",
      :sass  => "#{base}/stylesheets",
      :html  => "#{base}/partials",
      :asset => "#{asset}",
      :copy_to => {
        :js   => "public/javascripts/widgets/#{asset}",
        :css  => "public/stylesheets/widgets/#{asset}",
        :sass => "public/stylesheets/sass/widgets/#{asset}"
      },
    }
  end
  
end