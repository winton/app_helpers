module AppHelpers
  
  def render_widget(*path)
    widgets, options = widget_instances path
    widgets.collect do |w|
      if options[:include_js]
        w.render_init(:partials, options) + "\n<script type='text/javascript'>\n#{w.render_init :js, options}\n</script>"
      else
        javascripts *(@required_widget ? [ :layout => true ] : []) do
          w.render_init :js, options
        end
        w.render_init :partials, options
      end
    end
  end
  
  def require_widget(*path)
    widgets, options = widget_instances path
    widgets.each do |w|
      w.copy_assets
      javascripts *(w.helper_targets(:javascripts) + [ :cache => w.cache, :layout => true ]) do
        w.render_init(:js) if w != widgets.last
      end
      stylesheets *(w.helper_targets(:stylesheets) + [ :cache => w.cache, :layout => true ])
      templates   *(w.assets[:templates].collect do |t|
        [ File.basename(t), t, options.merge(:options => options) ]
      end)
    end
    @required_widget = true
  end
  
  def widget_image(*path)
    options = path.extract_options!
    image_tag widget_image_path(*path), options
  end
  
  def widget_image_path(*path)
    image = path.pop
    "widgets/#{path.join('/')}/#{image}"
  end
  
  def widget_partial(*path)
    options = path.extract_options!
    partial = path.pop
    path << options
    widgets, options = widget_instances path
    options = {
      :locals  => options.merge(:options => options),
      :partial => "#{path.join('/')}/partials/#{partial}"
    }
    render options
  end
  
  def widget_instances(path)
    @widgets ||= Widgets.new controller, logger
    options = path.extract_options!
    widgets = @widgets.build path, options
    [ widgets, options ]
  end
  
  class Widgets
    attr :paths,   true
    attr :widgets, true
    
    def initialize(controller, logger)
      @controller = controller
      @logger     = logger
      @widgets    = {}
    end
    
    def build(path, options)
      related_paths(path).collect do |r|
        @widgets[r] ||= Assets.new r, @controller, @logger
        options.merge! @widgets[r].options
        @widgets[r]
      end
    end
    
    private
    
    def related_paths(paths)
      last = paths.length - 1
      ordered = []
      last.step(0, -1) do |x|
        path = paths[x..last].join '/'
        if File.exists?("app/widgets/#{path}")
          ordered << path
        end
      end
      ordered
    end
    
    class Assets
      attr :assets,  true
      attr :cache,   true
      attr :options, true
      attr :path,    true
      
      ASSET_TYPES = [ :images, :javascripts, :stylesheets, :templates, :init_js, :init_partials ]
      
      def initialize(path, controller, logger)
        @controller = controller
        @logger  = logger
        @assets  = {}
        @options = {}
        @path    = path
        @cache   = cache_name
        update_options
        ASSET_TYPES.each do |type|
          update_asset type
        end
      end
      
      def copy_assets
        @assets.each do |key, value|
          from, to = to_path key
          value.each do |asset|
            base = File.basename asset
            f = [ from, base ].join '/'
            t = [ to,   base ].join '/'
            case key
            when :images
              FileUtils.mkdir_p to
              FileUtils.copy f, t
            when :javascripts, :stylesheets
              t.gsub!('/stylesheets/', '/stylesheets/sass/') if t.include?('.sass')
              FileUtils.mkdir_p File.dirname(t)
              File.open t, 'w' do |file|
                file.write @controller.render_to_string(:file => f, :locals => @options.merge(:options => @options))
              end
            end
          end
        end
      end
      
      def helper_targets(type)
        from, to = to_path type
        case type
        when :javascripts
          @assets[type].collect do |asset|
            [ to.split('javascripts/')[1], File.basename(asset, '.js') ].join '/'
          end
        when :stylesheets
          @assets[type].collect do |asset|
            sass = asset.include? '.sass'
            [ to.split('stylesheets/')[1], File.basename(asset, sass ? '.sass' : '.css') ].join '/'
          end
        else @assets[type]
        end
      end
      
      def render_init(type, options=@options)
        @assets["init_#{type}".intern].collect do |f|
          @controller.render_to_string :file => f, :locals => options.merge(:options => options)
        end.join("\n")
      end
      
      private
      
      def cache_name
        @path.empty? ? 'base' : @path.gsub('/', '_')
      end
      
      def filename_to_partial(file, remove=nil)
        base = File.basename file
        dir  = File.dirname file
        file = [ dir, (base[0..0] == '_' ? base[1..-1] : base ).split('.')[0..-2].join('.') ].join '/'
        if remove
          if remove.respond_to?(:pop)
            remove.each { |r| file.gsub! r, '' }
          else
            file.gsub! remove, ''
          end
        end
        file
      end

      def needs_update?(from, to)
        File.exists?(to) ? File.mtime(from) > File.mtime(to) : true
      end
      
      def to_path(type, path=@path)
        base = "app/widgets#{path.empty? ? '' : '/'}#{path}"
        case type
        when :base:          base
        when :init_js:       base + '/javascripts/init'
        when :init_partials: base + '/partials/_init'
        when :options:       base + '/options.rb'
        when :templates:     base + '/templates'
        when :images:      [ base + '/images',      'public/images/widgets/'      + path ]
        when :javascripts: [ base + '/javascripts', 'public/javascripts/widgets/' + path ]
        when :stylesheets: [ base + '/stylesheets', 'public/stylesheets/widgets/' + path ]
        end
      end
      
      def update_asset(type)
        @assets[type] ||= []
        from = to_path type
        from = from[0] if from.respond_to?(:pop)
        from = File.directory?(from) ? "#{from}/*" : "#{from}.*"
        Dir[from].sort.each do |f|
          next if type == :javascripts && File.basename(f) == 'init.js'
          @assets[type] << (type == :templates ? filename_to_partial(f, 'app/widgets/') : f)
        end
      end
      
      def update_options(path=@path, empty=false)
        options  = to_path :options, path
        @options = (File.exists?(options) ? eval(File.read(options)) : {}).merge(@options)
        path = path.split('/')[0..-2]
        # empty allows us to retrieve
        update_options(path.join('/'), path.empty?) unless empty
      end
    end
  end
end