namespace :import do
  
  task :documents => :environment do
    dir = '/var/www/pinpointlms.co.uk/shared/assets/bbooze/'
    user = User.find_by_name 'Linsey Bullock'

    Dir.open(dir).each do |file|
      code = file.match /^BRANCH ([\d]+)\.pdf/
      next unless code
      store = Store.find_by_account_number code[1]
      unless store
        puts "Store with account number #{code[1]} not found"
        next
      end
      document = Document.new file: File.open("#{dir}/#{file}"), title: file, document_type: 'demographic-map'
      document.store = store
      document.user = user
      document.save
      puts "Saving document #{file}"
    end
  end
end