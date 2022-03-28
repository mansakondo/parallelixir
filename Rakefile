# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test

gem_path = File.expand_path __dir__

Dir["#{gem_path}/lib/parallelixir/tasks/**/*.rake"].each do |task|
  import task
end
