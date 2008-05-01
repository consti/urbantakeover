module DashboardHelper
  def random_frontpage_image_url
    photo_dir = Dir.new(RAILS_ROOT+"/public/images/photos/")
    
    jpg_files = photo_dir.collect { |file| file if file.ends_with? ".jpg" }.compact
      
    random_jpg = jpg_files[rand(jpg_files.size)]
    return "/images/photos/#{random_jpg}"
  end
end
