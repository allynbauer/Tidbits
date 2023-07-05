require 'rake'
require 'rake/testtask'

desc "Run basic tests"
Rake::TestTask.new("test") { |t|
  t.pattern = 'lib/test/tests.rb'
  t.verbose = true
  t.warning = true
}