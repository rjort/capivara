# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__), 'lib', 'capivara', 'version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'capivara'
  s.version = Capivara::VERSION
  s.author = 'Reuter R. S. Junior'
  s.email = 'reuter_junior@hotmail.com'
  s.homepage = 'http://github.com/rjort'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A description of your project'
  s.files = `git ls-files`.split("\n")
  s.require_paths << 'lib'
  s.extra_rdoc_files = ['README.md', 'capivara.rdoc']
  s.rdoc_options << '--title' << 'capivara' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'capivara'
  s.add_runtime_dependency('colorize', '~> 1.1.0')
  s.add_runtime_dependency('gli', '~> 2.21.0')
  s.add_runtime_dependency('json', '~> 2.3.0')

  s.add_development_dependency('minitest', '~> 5.14')
  s.add_development_dependency('pry', '~> 0.14.2')
  s.add_development_dependency('pry-byebug', '~> 3.10.1')
  s.add_development_dependency('rake', '~> 0.9.2')
  s.add_development_dependency('rdoc', '~> 4.3')
  s.add_development_dependency('rubocop', '~> 1.50')
end
