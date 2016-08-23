namespace :provision do
  desc 'provisions app box'
  task :app do
    require 'net/ssh'
    require 'net/scp'
    user = 'root'
    server = '134.213.154.153'
    puts '==================== Starting ===================='
    `tar -zcf puppet.tar puppet`

    ssh = Net::SSH.start(server, user)
    ssh.scp.upload!('puppet.tar', 'puppet.tar')
    ssh.exec!('tar -zxf puppet.tar') {|ch, stream, line| puts line }
    ssh.exec!('cd puppet && puppet apply -dtv manifests/prod/app.pp --modulepath=modules/') {|ch, stream, line| puts line }
    ssh.close

    puts '==================== Finished ===================='
  end
end