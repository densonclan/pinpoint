namespace :provision do
  desc 'provisions app box'
  task :app, [:ip_address] do |task, args|
    require 'net/ssh'
    require 'net/scp'
    user = 'root'
    server = args[:ip_address] # '134.213.154.153'
    puts "IP Address = #{ server }"
    puts '==================== Starting ===================='
    `tar -zcf puppet.tar puppet`

    ssh = Net::SSH.start(server, user)
    ssh.scp.upload!('puppet.tar', 'puppet.tar')
    ssh.exec!('tar -zxf puppet.tar') {|ch, stream, line| puts line }
    ssh.exec!('cd puppet && puppet apply -dv manifests/prod/app.pp --modulepath=modules/') {|ch, stream, line| puts line }
    ssh.close

    puts '==================== Finished ===================='
  end

  desc 'provisions db box'
  task :db, [:ip_address] do |task, args|
    require 'net/ssh'
    require 'net/scp'
    user = 'root'
    server = args[:ip_address] # '134.213.154.153'
    puts "IP Address = #{ server }"
    puts '==================== Starting ===================='
    `tar -zcf puppet.tar puppet`

    ssh = Net::SSH.start(server, user)
    ssh.scp.upload!('puppet.tar', 'puppet.tar')
    ssh.exec!('tar -zxf puppet.tar') {|ch, stream, line| puts line }
    ssh.exec!('cd puppet && puppet apply -dv manifests/prod/db.pp --modulepath=modules/') {|ch, stream, line| puts line }
    ssh.close

    puts '==================== Finished ===================='
  end

end
