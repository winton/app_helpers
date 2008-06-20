Dir[File.expand_path('*/*.rb', File.dirname(__FILE__))].each do |f|
  f = f.split('/')
  require File.join(File.dirname(__FILE__), [ f[-2], File.basename(f[-1], '.rb') ].join('/'))
end

ActionView::Base.send :include, AppHelpers
ActionController::Base.view_paths.push RAILS_ROOT + '/app/widgets'
ActionController::Base.class_eval do
  public :render_to_string
end