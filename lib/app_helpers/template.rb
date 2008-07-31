module AppHelpers
  
  def textarea_template(id, path=nil, locals={})
    controller.render_to_string(:partial => 'app_helpers/template/textarea', :locals => {
      :id => id,
      :body => controller.render_to_string(:partial => path, :locals => locals)
    })
  end

end