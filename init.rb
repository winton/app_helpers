require 'app_helpers'

ActionView::Base.send :include, AppHelpers
ActionController::Base.view_paths += [ RAILS_ROOT + '/app/widgets' ]
ActionController::Base.class_eval do
  public :render_to_string
end