namespace :pinpoint do
  
  task :run_imports => :environment do
    Transport.run_pending_imports
  end
end