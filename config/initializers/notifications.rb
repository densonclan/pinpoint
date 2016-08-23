hash = YAML.load(File.read(Rails.root.join('config/notifications.yml')))

Rails.configuration.notifications = hash
