# encoding: utf-8

##
# Backup Generated: my_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t my_backup [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://meskyanichi.github.io/backup
#
Model.new(:my_backup, 'Description for my_backup') do

  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL do |db|
    db.name               = "pinpoint_production"
    # db.username           = "<from config>"
    # db.password           = "<from config>"
    db.host               = "localhost"
    db.port               = 5432
    # db.socket             = "/tmp/pg.sock"
    # db.skip_tables        = ["skip", "these", "tables"]
    # db.only_tables        = ["only", "these", "tables"]
    # db.additional_options = ["-xc", "-E=utf8"]
  end

  compress_with Gzip

  store_with CloudFiles do |cf|
    # cf.api_key            = '<from config>'
    # cf.username           = '<from config>'
    # cf.container          = '<from config>'
    # cf.region             = <from config>
    # cf.segments_container = 'my_segments_container' # must be different than `container`
    # cf.segment_size       = 5 # MiB
    cf.path               = '/database' # path within the container
  end

  sync_with Cloud::CloudFiles do |cf|
    # cf.username          = "<from config>"
    # cf.api_key           = "<from config>"
    # cf.container          = '<from config>'
    # cf.region             = <from config>
    cf.path              = "/documents"
    cf.mirror            = true
    cf.thread_count      = 10

    cf.directories do |directory|
      directory.add "/var/www/pinpoint/shared/public/system/"
      directory.add "/var/www/pinpoint/shared/public/logos/"

      # Exclude files/folders from the sync.
      # The pattern may be a shell glob pattern (see `File.fnmatch`) or a Regexp.
      # All patterns will be applied when traversing each added directory.
      directory.exclude '**/*~'
      directory.exclude /\/tmp$/
    end
  end

  notify_by FlowDock do |flowdock|
    flowdock.on_success = false
    flowdock.on_warning = false
    flowdock.on_failure = true

    flowdock.token      = "fa204700846298b252bd785694a1a650"
    flowdock.from_name  = 'Database Backup'
    flowdock.from_email = 'support@sourcelab.technology'
    flowdock.subject    = 'Database Backup'
    flowdock.source     = 'Backup'
    flowdock.tags       = ['prod', 'backup']
  end

  notify_by Mail do |mail|
    mail.on_success           = false
    mail.on_warning           = false
    mail.on_failure           = true

    mail.from                 = 'support+backup@sourcelab.technology'
    mail.to                   = 'support@sourcelab.technology'
    mail.address              = 'smtp.mailgun.org'
    mail.port                 = 587
    mail.domain               = 'pinpointlms.co.uk'
    mail.user_name            = 'postmaster@mail.pinpointlms.co.uk'
    mail.password             = 'c7ce6bb3e933f129752e9f640fa35fc4'
    mail.authentication       = 'plain'
    mail.encryption           = :starttls
  end


end