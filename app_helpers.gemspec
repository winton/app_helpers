Gem::Specification.new do |s|
  s.name    = 'app_helpers'
  s.version = '1.0.2'
  s.date    = '2008-08-16'
  
  s.summary     = "A collection of useful Rails application helpers and rake tasks"
  s.description = "A collection of useful Rails application helpers and rake tasks"
  
  s.author   = 'Winton Welsh'
  s.email    = 'mail@wintoni.us'
  s.homepage = 'http://github.com/winton/app_helpers'
  
  s.has_rdoc = false
  
  s.files = Dir[*%w(
    init.rb
    lib/*
    lib/**/*
    MIT-LICENSE
    README.markdown
    resources/**/*
    tasks/*
  )]
end
