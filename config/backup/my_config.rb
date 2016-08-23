# Backup v4.x Configuration
Database::PostgreSQL.defaults do |db|
  db.username           = "pinpoint"
  db.password           = "P1nP01nt!"
end

Storage::CloudFiles.defaults do |cf|
  cf.api_key            = '57bb8ac9af8c471cb8a6726e50a166a7'
  cf.username           = 'pinpointlms'
  cf.region             = :lon
  cf.container          = 'backups'
end

Syncer::Cloud::CloudFiles.defaults do |cf|
  cf.api_key            = '57bb8ac9af8c471cb8a6726e50a166a7'
  cf.username           = 'pinpointlms'
  cf.region             = :lon
  cf.container          = "backups"
end

