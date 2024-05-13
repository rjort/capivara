require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
Rake::RDocTask.new do |rd|
  rd.main = 'README.rdoc'
  rd.rdoc_files.include('README.md', 'lib/**/*.rb', 'bin/**/*')
  rd.title = 'Minitool for extend capybara automation development'
end

spec = eval(File.read('capivara.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end

task default: :test
