class PanoramioController < ActionController::Base

  def view
    headers["Content-Type"] = "text/javascript"
    require 'open-uri'
    @json = open('http://www.panoramio.com/map/get_panoramas.php?order=upload_date&set=1730278&from=0&to=20&minx='+ params[:minx] +'&miny='+ params[:miny] +'&maxx='+ params[:maxx] +'&maxy='+ params[:maxy]+'&size=thumbnail').read
  end
  
end
