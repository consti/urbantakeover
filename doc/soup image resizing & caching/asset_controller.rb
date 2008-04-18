require 'mini_magick'

class AssetController < ApplicationController
  skip_before_filter :load_blog
  session :disable
   
  def file_not_found
    begin
      # We received something params[:file] of format id_name_size
      # The problem is that name can contain underscore too, so we split by _
      # take first value as id, last as size, and everything left as name
      values = params[:file].split(/_/)
      
      file = values.shift
      size = values.pop
      name = values.join('_')
      
      id = (params[:dir] + file).to_i
  
      asset = Asset.find(:first, :conditions => ['id = ? AND name = ? AND ext = ?',id,name,params[:ext]])
      ## try finding this asset
      # TODO: check size
      if asset
        # Do not upscale images, and do not resize non-images 
        if asset.type.image? && size.to_i < asset.data.width
          resize!(asset.physical_path,asset.physical_path(size),size)
        else
          size = nil # Redirect to original asset
        end
        redirect_to asset.url(size)
      else
        render :nothing => true, :status => 404
      end
    rescue => e
      SOUP_LOGGER.error("Asset controller: #{e.message} (#{id}_#{name})")
      render :nothing => true, :status => 500
    end
  end

private
  def resize!(src,dest,new_width)
    image = Magick::Image::read(src).first
    new_image = image.resize(new_width.to_f / image.columns)
    new_image.write(dest)
    
    # Pass a hint to ruby to GC the image's data in foreign space.
    new_image = image = []
    GC.start
  end
end
