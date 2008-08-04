require 'app_helpers'

ActionView::Base.send :include, AppHelpers
ActionController::Base.send :include, AppHelpers
ActionController::Base.class_eval do
  public :render_to_string
end