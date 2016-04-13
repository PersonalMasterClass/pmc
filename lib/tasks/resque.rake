require 'resque/tasks'
require 'resque-delayed/tasks'
task "resque:setup" => :environment
