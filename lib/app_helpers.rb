Dir[File.expand_path('*/*.rb', File.dirname(__FILE__))].each do |f|
  require [ File.dirname(f), File.basename(f, '.rb') ].join('/')
end

ActionView::Base.send :include, AppHelpers
ActionController::Base.view_paths += RAILS_ROOT + '/app/widgets'
ActionController::Base.class_eval do
  public :render_to_string
end