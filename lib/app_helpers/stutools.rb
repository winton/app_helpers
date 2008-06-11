module AppHelpers

  def mootools
    RAILS_ENV == 'development' ? 'stutools/assets/moo' : 'moo'
  end

  def stutools
    if RAILS_ENV == 'development'
      Dir[RAILS_ROOT + "/public/javascripts/stutools/*.js"].collect { |f| 'stutools/' + File.basename(f, '.js') }
    else
      'stu'
    end
  end

end