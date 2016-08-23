root_path = '/vagrant/'
Dir.glob(root_path + "public/logos/*.BMP").each do |file|
  # p `identify -format "%w x %h %x x %y" #{file}` rescue file
  ppcm = `identify -format "%x" #{file}` rescue next
  ppcm = ppcm.to_f
  next if ppcm == 0.0
  `convert #{file} -resize #{ppcm*8}x#{ppcm*29.7}\! #{file}`
end
