class Asset < ActiveRecord::Base
  has_metadata
  
  DIRECTORY = 'asset'
  ROOT = File.join(RAILS_ROOT,'public')
  MAX_IMAGE_SIZE = 1_200 # we want to be able to print these on A5 @300dpi (2400x1800
  
  module Types
    IMAGE = %w(jpg jpeg gif png tif tiff)
    BROWSER_SUPPORTED_IMAGE = IMAGE - %w(tif tiff)
    AUDIO = %w(mp3)
    SCRIBD_SUPPORTED = %(doc ppt pps xls odt odp sxw sxi txt rdf pdf ps)
  end
  
  # Return an object that allows queries of this asset type such as image?, css? etc. 
  # Type.list gives you the list of all types it belongs to
  # Examples:
  #   Asset.new(:ext => 'png').type.list # ["png", "browser_supported_image", "image"]
  #   Asset.new(:ext => 'png').type.image? # true
  def type
    result = [self.ext]
    result += Types.constants.select { |c| Types.const_get(c).include?(self.ext) }.map {|c| c.downcase}
    returning(Querable.new(result)) { |q| q.list = result }
  end
  
  # Name per default is a random hex value that we append to disallow sequential crawling of nameless assets
  default :name do |a| 
    a.name = rand(0xffff).to_s(16).rjust(4,'0') 
  end
  
  attr_writer :body
  def body
    File.read(physical_path)
  end
  
  def body=(value)
    @body = value
    self.data.size = @body.length
  end
  
  # Make sure extension is always normalized (downcase, no dots) 
  def ext=(e)
    super(e.ergo.gsub(/\./,'').downcase)
  end
  
  # Clean up name
  #def name=(n)
  #  super(n && n.gsub(/\s+/,'_').gsub('..','').gsub('/','').gsub("\\",''))
  #end
  
  def self.from(arg,options = {},&block)
    returning Asset.new do |asset|
      case arg
        when File,Tempfile,StringIO
          # As path (needed to extract extension) we try to take original_path if asset originates from an upload
          # or local path otherwise
          if arg.respond_to?(:original_filename) 
            path = arg.original_filename
          else
            path = arg.path
          end
          
          # Now we extract extension from that path...
          asset.ext = File.extname(path)
          # Call process_image here, in case the file supplied is an image
          # (will be auto-detected by image magick)
          asset.process_image(arg,&block) || begin
            arg.binmode
            arg.rewind
            asset.body = arg.read
            #asset.name = File.basename(path,File.extname(path)) # TODO: this should depend on whether the upload is image or not, but use special flag instead 
          end
        when Hash
          # 'css' => 'somecontent'
          # convert this constructor hash to pair of values and assign them appropriately
          asset.ext, asset.body = arg.keys.first.to_s, arg.values.first
      end
      asset.save!
      GC.start
    end
  end
  
  def after_save
    FileUtils.mkdir_p File.dirname(self.physical_path) #  Make sure the directory exists
    File.open(self.physical_path,'wb') { |f| f.write(@body) } if @body 
  end
  
  def before_destroy
    # delete original file and all possible variations such as other sizes
    files = Dir.glob physical_path('*') # all variations...
    files << physical_path # ..+ original
    files.each {|f| File.delete(f) if File.exist?(f)}
  end
  
  def process_image(file)
    # Try parsing the file through image magick but if it fails, return
    image = Magick::Image::from_blob(file.binmode.read).first rescue (return nil)
   
    self.ext = image.format
    
    # Convert non-browser formats to PNG
    unless self.type.browser_supported_image?
      self.ext = image.format = 'png'
    end
    
    if block_given?
      # the caller will process the image, we do nothing
      yield(image) if block_given?
    else
      # Limit the size of image to MAXIMUM_SIZE: if scale < 1 that means that we need 
      # to resize down, if it's >= 1, then the image is smaller than the MAXIMUM_SIZE 
      # so we leave it as it is
      scale = MAX_IMAGE_SIZE / [image.columns, image.rows].max.to_f
      image.resize!(scale) if scale < 1
    end
    
    self.data = { :height => image.rows, :width => image.columns }
    self.body = image.to_blob
  end
  
  def path(param = nil)
    suffix = ['',name,param].compact.join('_') # will produce _name_param or _name if no param specified
    (File.join(DIRECTORY,*('%08d' % id).scan(/..../)) + "#{suffix}.#{ext}").downcase
  end

  def physical_path(param = nil)
    File.expand_path File.join(ROOT,path(param))
  end

  def url(param = nil)
    "http://#{Portier.address_of(:asset)}/#{path(param)}"
  end
  
  def full_name
    [name,ext].join('.')
  end

  # We use the field +name+ to annotate 'special' assets, for example
  # image of default/anonymous avatar etc. This is conveneice method
  # for looking-up such assets, i.e. +Asset['avatar']+ 
  def self.[](name)
    self.find_by_name(name)
  end
end  

if RAILS_ENV == 'development'
  # Patch asset to say that assets have url of a remote server for the ones that
  # we don't locally have
  class Asset
    alias :orig_url :url
    def url(size=nil)
      returning orig_url(size) do |u|
        u.gsub!('.local','').gsub!(/\:\d+/,'') if !File.exist?(physical_path)
      end
    end
  end
end

if RAILS_ENV == 'qa'
  # Patch asset to say that assets have url of a remote server for the ones that
  # we don't locally have
  class Asset
    alias :orig_url :url
    def url(size=nil)
      returning orig_url(size) do |u|
        u.gsub!('.qa','').gsub!(/\:\d+/,'') if !File.exist?(physical_path)
      end
    end
  end
end
