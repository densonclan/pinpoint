# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "#{path}/log/cron.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end

#
# Every 4 days, check for period dates and orders being completed/expired
#
every 4.days do
  # runner "AnotherModel.prune_old_records"
  rake 'check:orders'
  rake 'check:dates'
end

#
# Every day, check for tasks
#
every 1.day, :at => '9:30 am' do
    rake 'check:due_tasks'
end

every 10.minutes do
  rake 'pinpoint:run_imports'
end

every 1.day, :at => '1:00 am' do
  command '/usr/local/bin/backup perform -t my_backup --config-file /var/www/pinpoint/current/config/backup/my_config.rb'
end

# Learn more: http://github.com/javan/whenever
