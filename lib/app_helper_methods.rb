module AppHelperMethods
  
  def self.included(base)
    base.helper_method :render_to_string
  end
  
end