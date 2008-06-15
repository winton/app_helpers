ActionView::Base.send :include, AppHelpers
ActionController::Base.send :include, AppHelperMethods
ActionController::Base.view_paths.push RAILS_ROOT + '/app/widgets'