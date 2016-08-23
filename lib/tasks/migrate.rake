namespace :migrate do
  
  task :export_templates => :environment do
    ExportTemplate.all.each do |et|
      et.value = et.value.gsub(/Royal Mail\-/, 'Distribution-')
      et.value = et.value.gsub(/Store Delivery\-/, 'Distribution-')
      et.value = et.value.gsub(/Newspaper\-/, 'Distribution-')
      et.value = et.value.gsub(/Solus Team\-/, 'Distribution-')
      et.value += ',Distribution-Type,' if et.value =~ /Distribution\-/
      et.value = et.value.split(',').uniq.join(',')
      et.save
    end
  end

  task :duplicate_addresses => :environment do
    Address.order(:id).each do |a|
      dup = Address.where(title: a.title, full_name: a.full_name, first_line: a.first_line, second_line: a.second_line, third_line: a.third_line, city: a.city, postcode: a.postcode, county: a.county, phone_number: a.phone_number, email: a.email, address_type: a.address_type, business_name: a.business_name, mobile: a.mobile).where("id < #{a.id}").order(:id).pluck(:id).first
      if dup
        puts "address_id=#{a.id} WHERE address_id =#{dup}"
        Store.update_all("address_id=#{a.id}", "address_id =#{dup}")
        Distribution.update_all("address_id=#{a.id}", "address_id =#{dup}")
        Distribution.update_all("publisher_id=#{a.id}", "address_id =#{dup}")
        Address.delete_all("id =#{dup}")
      end
    end
  end

  task :duplicate_addresses2 => :environment do
    Address.order(:id).each do |a|
      dup = Address.where(address_type: a.address_type, business_name: a.business_name, full_name: a.full_name, postcode: a.postcode).where("id < #{a.id}").order(:id).pluck(:id).first
      if dup
        puts "address_id=#{a.id} WHERE address_id =#{dup}"
        Store.update_all("address_id=#{a.id}", "address_id =#{dup}")
        Distribution.update_all("address_id=#{a.id}", "address_id =#{dup}")
        Distribution.update_all("publisher_id=#{a.id}", "address_id =#{dup}")
        Address.delete_all("id =#{dup}")
      end
    end
  end


end