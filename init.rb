require 'app_helpers'
require 'app_helper_methods'

ActionView::Base.send :include, AppHelpers
ActionController::Base.send :include, AppHelperMethods
ActionController::Base.view_paths.push RAILS_ROOT + '/app/widgets'
ActionController::Base.class_eval do
  public :render_to_string
end