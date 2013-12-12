require 'bard/rake/db_multiple_environment_sanity'
require 'bard/rake/db_dump_load'
require 'bard/rake/bootstrap'
require 'bard/rake/testing'

def invoke_task_if_exists task_name
  Rake::Task[task_name].invoke if Rake::Task.task_defined? task_name
end

module Bard::Rake
end
