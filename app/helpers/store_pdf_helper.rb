require 'RMagick'

module StorePdfHelper

  def convert_to_jpg(source, destination)
    thumb = Magick::Image.read(source).first
    thumb.resize_to_fit!(350)
    thumb.format = "JPG"
    thumb.write(destination)
  end

  def logo_jpg_path(store)
    Rails.root.join('public', 'logos', "#{store.logo}.jpg")
  end

  def store_jpg_logo(store)
    jpg = logo_jpg_path(store)
    convert_to_jpg(logo_path(store), jpg) unless File.exists? jpg
    jpg
  end
end