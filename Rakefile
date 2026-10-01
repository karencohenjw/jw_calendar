# frozen_string_literal: true

require "rake/testtask"
require "yard"

Rake::TestTask.new(:test) do |task|
  task.libs << "lib" << "test"
  task.pattern = "test/**/*_test.rb"
end

desc "Run RuboCop"
task :lint do
  sh "bundle exec rubocop"
end

desc "Build the gem archive"
task :build do
  sh "gem build jw_calendar.gemspec"
end

desc "Generate API documentation with YARD"
YARD::Rake::YardocTask.new(:yard) do |yard|
  yard.files = ["lib/**/*.rb"]
  yard.options = ["--markup", "markdown", "--readme", "README.md"]
end

task default: %i[test lint build]
