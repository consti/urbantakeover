var map, cluster;
var gmarkers = [];

function mapini() {
  /* EINSERT */	
 	  function EInsert(point, image, size, basezoom, zindex) {
       this.point = point;
       this.image = image;
       this.size = size;
       this.basezoom = basezoom;
       this.zindex=zindex||0;
       // Is this IE, if so we need to use AlphaImageLoader
       var agent = navigator.userAgent.toLowerCase();

       if ((agent.indexOf("msie") > -1) && (agent.indexOf("opera") < 1)){this.ie = true} else {this.ie = false}
       this.hidden = false;
     } 

     EInsert.groundOverlay = function(image, bounds, zIndex, proj,z) {
       var proj = proj||G_NORMAL_MAP.getProjection();              
       var z = z||17;
       var sw = proj.fromLatLngToPixel(bounds.getSouthWest(),z);
       var ne = proj.fromLatLngToPixel(bounds.getNorthEast(),z);
       var cPixel = new GPoint((sw.x+ne.x)/2, (sw.y+ne.y)/2);
       var c = proj.fromPixelToLatLng(cPixel,z);
       var s = new GSize(ne.x-sw.x, sw.y-ne.y);
       return new EInsert(c, image, s, z, zIndex);
     }

 		EInsert.prototype = new GOverlay();

     EInsert.prototype.initialize = function(map) {
       var div = document.createElement("div");
       div.style.position = "absolute";
       div.style.zIndex=this.zindex;
       if (this.zindex < 0) {
          map.getPane(G_MAP_MAP_PANE).appendChild(div);
       } else {
          map.getPane(1).appendChild(div);
       }
       this.map_ = map;
       this.div_ = div;
     }

     EInsert.prototype.makeDraggable = function() {
       this.dragZoom_ = this.map_.getZoom();
       this.dragObject = new GDraggableObject(this.div_);

       this.dragObject.parent = this;

       GEvent.addListener(this.dragObject, "dragstart", function() {
         this.parent.left=this.left;
         this.parent.top=this.top;
       });


       GEvent.addListener(this.dragObject, "dragend", function() {
         var pixels = this.parent.map_.fromLatLngToDivPixel(this.parent.point);
         var newpixels = new GPoint(pixels.x + this.left - this.parent.left, pixels.y +this.top -this.parent.top);
         this.parent.point = this.parent.map_.fromDivPixelToLatLng(newpixels);
         this.parent.redraw(true);
         GEvent.trigger(this.parent, "dragend", this.parent.point);
       });    
     }

     EInsert.prototype.remove = function() {
       this.div_.parentNode.removeChild(this.div_);
     }

     EInsert.prototype.copy = function() {
       return new EInsert(this.point, this.image, this.size, this.basezoom);
     }

     EInsert.prototype.redraw = function(force) {
      if (force) {
       var p = this.map_.fromLatLngToDivPixel(this.point);
       var z = this.map_.getZoom();
       var scale = Math.pow(2,(z - this.basezoom));
       var h=this.size.height * scale;
       var w=this.size.width * scale;

       this.div_.style.left = (p.x - w/2) + "px";
       this.div_.style.top = (p.y - h/2) + "px";

       if (this.ie) {
         var loader = "filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+this.image+"', sizingMethod='scale');";
         this.div_.innerHTML = '<div style="height:' +h+ 'px; width:'+w+'px; ' +loader+ '" ></div>';
       } else {
         this.div_.innerHTML = '<img src="' +this.image+ '"  class="area" width='+w+' height='+h+' >';
       }

       // Only draggable if current zoom = the initial zoom
       if (this.dragObject) {
         if (z != this.dragZoom_) {this.dragObject.disable();}
       }

      } 
     }

     EInsert.prototype.show = function() {
       this.div_.style.display="";
       this.hidden = false;
     }

     EInsert.prototype.hide = function() {
       this.div_.style.display="none";
       this.hidden = true;
     }

     EInsert.prototype.getPoint = function() {
       return this.point;
     }

     EInsert.prototype.supportsHide = function() {
       return true;
     }

     EInsert.prototype.isHidden = function() {
       return this.hidden;
     }

     EInsert.prototype.setPoint = function(a) {
       this.point = a;
       this.redraw(true);
     }

     EInsert.prototype.setImage = function(a) {
       this.image = a;
       this.redraw(true);
     }

     EInsert.prototype.setZindex = function(a) {
       this.div_.style.zIndex=a;
     }

     EInsert.prototype.setSize = function(a) {
       this.size = a;
       this.redraw(true);
     }
   /* EINSERT END */
   
	if (GBrowserIsCompatible()) {

		map=new GMap2(document.getElementById('map'));
		map.setCenter(new GLatLng(0, 0), 0, G_NORMAL_MAP);

		map.addControl(new GMapTypeControl());
		map.addControl(new GLargeMapControl());

		map.hideControls();
	
		map.enableScrollWheelZoom();
		new GKeyboardHandler(map);		
		
		var baseIcon = new GIcon();
		baseIcon.iconSize = new GSize(25, 13);
		baseIcon.iconAnchor = new GPoint(10, 13);
		baseIcon.infoWindowAnchor = new GPoint(19, 2);
		baseIcon.infoShadowAnchor = new GPoint(22, 2);
		
		var marker, markersArray=[];
		
		for (var i=0; i<json.length; i++) {
			if(json[i][2][0] && json[i][0] == focus_spot) {
				marker=newMarker(new GLatLng(json[i][4], json[i][5]), json[i][0], json[i][1], json[i][2], json[i][3], baseIcon, true);
				map.addOverlay(marker);
	         	GEvent.trigger(marker, "click");				
			} else if (json[i][2][0]) {
				marker=newMarker(new GLatLng(json[i][4], json[i][5]), json[i][0], json[i][1], json[i][2], json[i][3], baseIcon, false);
			}
			  var undefined;
			    mefarbe = "#DDDDDD" || json[i][2][0][2];
			    farbe = me.replace(/#/,"");
          map.addOverlay(new EInsert(new GLatLng(json[i][4], json[i][5]), "/images/areas/"+farbe+".png", new GSize(0.0005,0.0005), -1));
        }  
				markersArray.push(marker);
		}

		GEvent.addListener(map, "mouseover", function(){
		map.showControls();
		});

		GEvent.addListener(map, "mouseout", function(){
		map.hideControls(); 
		});

		cluster=new ClusterMarker(map, { markers:markersArray } );
		if (focus_spot == "") {
			cluster.fitMapToMarkers();
		} else {
			map.setZoom(15);
		}

		map.savePosition();

	}

}

function newMarker(markerLocation, spotId, addr, users, mrkclr, baseIcon, selected) {
	var utoicon = new GIcon(baseIcon);
	utoicon.image = "/images/marker/"+mrkclr+".png";
	var marker=new GMarker(markerLocation, {icon: utoicon, title:'Spot['+spotId+']'});
	var infoMsg='<div class="markermsg"><a href="/spot/'+spotId+'" class="spot-name">'+spotId+'</a><br/>';
		if(addr!=null) {
			infoMsg+='<span class=\"address\">'+addr+'</span>';
		} else {
			infoMsg+='<span class=\"address\">'+spotId+'</span>';
		}
		infoMsg+='<br/>current: <a href=\"/user/'+users[0][0]+'\" class=\"user-name\" style=\"background-color:'+users[0][1]+';border-color:'+users[0][2]+';\">'+users[0][0]+'</a><br/>';
		infoMsg+='here: <a href\"/user/'+users[0][0]+'" class=\"user-name\" style=\"background-color:'+users[0][1]+';border-color:'+users[0][2]+';\">'+users[0][0]+'</a>';
		for(var i=1;i<users.length; i++) {
			infoMsg+=', <a href\"/user/'+users[i][0]+'" class=\"user-name\" style=\"background-color:'+users[i][1]+';border-color:'+users[i][2]+';\">'+users[i][0]+'</a>';
		}
		infoMsg+='<br/><a href=\"http://flickr.com/photos/tags/'+spotId+'\">Tag on flickr</a> & <a href=\"http://flickr.com/search/groups/?q='+spotId+'&w=697289%40N21&m=pool\">in uto group</a></div>';
	
	GEvent.addListener(marker, 'click', function() {
		marker.openInfoWindowHtml(infoMsg);
	});
	
	if (selected) {
        map.setCenter(markerLocation, 13);
	}
	return marker;
}

function toggleClustering() {
	cluster.clusteringEnabled=!cluster.clusteringEnabled;
	cluster.refresh(true);
}

// http://googlemapsapi.martinpearman.co.uk/clustermarker

function ClusterMarker($map, $options){
	this._map=$map;
	this._mapMarkers=[];
	this._iconBounds=[];
	this._clusterMarkers=[];
	this._eventListeners=[];
	if(typeof($options)==='undefined'){
		$options={};
	}
	this.borderPadding=($options.borderPadding)?$options.borderPadding:256;
	this.clusteringEnabled=($options.clusteringEnabled===false)?false:true;
	if($options.clusterMarkerClick){
		this.clusterMarkerClick=$options.clusterMarkerClick;
	}
	if($options.clusterMarkerIcon){
		this.clusterMarkerIcon=$options.clusterMarkerIcon;
	}else{
		this.clusterMarkerIcon=new GIcon();
		this.clusterMarkerIcon.image='/images/marker/group.png';
		this.clusterMarkerIcon.iconSize=new GSize(39, 21);
		this.clusterMarkerIcon.iconAnchor=new GPoint(17, 21);
		this.clusterMarkerIcon.infoWindowAnchor=new GPoint(33, 2);
	}
	this.clusterMarkerTitle=($options.clusterMarkerTitle)?$options.clusterMarkerTitle:'Click to zoom in and see %count markers';
	if($options.fitMapMaxZoom){
		this.fitMapMaxZoom=$options.fitMapMaxZoom;
	}
	this.intersectPadding=($options.intersectPadding)?$options.intersectPadding:0;
	if($options.markers){
		this.addMarkers($options.markers);
	}
	GEvent.bind(this._map, 'moveend', this, this._moveEnd);
	GEvent.bind(this._map, 'zoomend', this, this._zoomEnd);
	GEvent.bind(this._map, 'maptypechanged', this, this._mapTypeChanged);
}

ClusterMarker.prototype.addMarkers=function($markers){
	var i;
	if(!$markers[0]){
		//	assume $markers is an associative array and convert to a numerically indexed array
		var $numArray=[];
		for(i in $markers){
			$numArray.push($markers[i]);
		}
		$markers=$numArray;
	}
	for(i=$markers.length-1; i>=0; i--){
		$markers[i]._isVisible=false;
		$markers[i]._isActive=false;
		$markers[i]._makeVisible=false;
	}
	this._mapMarkers=this._mapMarkers.concat($markers);
};

ClusterMarker.prototype._clusterMarker=function($clusterGroupIndexes){
	function $newClusterMarker($location, $icon, $title){
		return new GMarker($location, {icon:$icon, title:$title});
	}
	var $clusterGroupBounds=new GLatLngBounds(), i, $clusterMarker, $clusteredMarkers=[], $marker, $this=this;
	for(i=$clusterGroupIndexes.length-1; i>=0; i--){
		$marker=this._mapMarkers[$clusterGroupIndexes[i]];
		$marker.index=$clusterGroupIndexes[i];
		$clusterGroupBounds.extend($marker.getLatLng());
		$clusteredMarkers.push($marker);
	}
	$clusterMarker=$newClusterMarker($clusterGroupBounds.getCenter(), this.clusterMarkerIcon, this.clusterMarkerTitle.replace(/%count/gi, $clusterGroupIndexes.length));
	$clusterMarker.clusterGroupBounds=$clusterGroupBounds;	//	only req'd for default cluster marker click action
	this._eventListeners.push(GEvent.addListener($clusterMarker, 'click', function(){
		$this.clusterMarkerClick({clusterMarker:$clusterMarker, clusteredMarkers:$clusteredMarkers });
	}));
	return $clusterMarker;
};

ClusterMarker.prototype.clusterMarkerClick=function($args){
	this._map.setCenter($args.clusterMarker.getLatLng(), this._map.getBoundsZoomLevel($args.clusterMarker.clusterGroupBounds));
};

ClusterMarker.prototype._filterActiveMapMarkers=function(){
	var $borderPadding=this.borderPadding, $mapZoomLevel=this._map.getZoom(), $mapProjection=this._map.getCurrentMapType().getProjection(), $mapPointSw, $activeAreaPointSw, $activeAreaLatLngSw, $mapPointNe, $activeAreaPointNe, $activeAreaLatLngNe, $activeAreaBounds=this._map.getBounds(), i, $marker, $uncachedIconBoundsIndexes=[], $oldState;
	if($borderPadding){
		$mapPointSw=$mapProjection.fromLatLngToPixel($activeAreaBounds.getSouthWest(), $mapZoomLevel);
		$activeAreaPointSw=new GPoint($mapPointSw.x-$borderPadding, $mapPointSw.y+$borderPadding);
		$activeAreaLatLngSw=$mapProjection.fromPixelToLatLng($activeAreaPointSw, $mapZoomLevel);
		$mapPointNe=$mapProjection.fromLatLngToPixel($activeAreaBounds.getNorthEast(), $mapZoomLevel);
		$activeAreaPointNe=new GPoint($mapPointNe.x+$borderPadding, $mapPointNe.y-$borderPadding);
		$activeAreaLatLngNe=$mapProjection.fromPixelToLatLng($activeAreaPointNe, $mapZoomLevel);
		$activeAreaBounds.extend($activeAreaLatLngSw);
		$activeAreaBounds.extend($activeAreaLatLngNe);
	}
	this._activeMarkersChanged=false;
	if(typeof(this._iconBounds[$mapZoomLevel])==='undefined'){
		//	no iconBounds cached for this zoom level
		//	no need to check for existence of individual iconBounds elements
		this._iconBounds[$mapZoomLevel]=[];
		this._activeMarkersChanged=true;	//	force refresh(true) as zoomed to uncached zoom level
		for(i=this._mapMarkers.length-1; i>=0; i--){
			$marker=this._mapMarkers[i];
			$marker._isActive=$activeAreaBounds.containsLatLng($marker.getLatLng())?true:false;
			$marker._makeVisible=$marker._isActive;
			if($marker._isActive){
				$uncachedIconBoundsIndexes.push(i);
			}
		}
	}else{
		//	icondBounds array exists for this zoom level
		//	check for existence of individual iconBounds elements
		for(i=this._mapMarkers.length-1; i>=0; i--){
			$marker=this._mapMarkers[i];
			$oldState=$marker._isActive;
			$marker._isActive=$activeAreaBounds.containsLatLng($marker.getLatLng())?true:false;
			$marker._makeVisible=$marker._isActive;
			if(!this._activeMarkersChanged && $oldState!==$marker._isActive){
				this._activeMarkersChanged=true;
			}
			if($marker._isActive && typeof(this._iconBounds[$mapZoomLevel][i])==='undefined'){
				$uncachedIconBoundsIndexes.push(i);
			}
		}
	}
	return $uncachedIconBoundsIndexes;
};

ClusterMarker.prototype._filterIntersectingMapMarkers=function(){
	var $clusterGroup, i, j, $mapZoomLevel=this._map.getZoom();
	for(i=this._mapMarkers.length-1; i>0; i--)
	{
		if(this._mapMarkers[i]._makeVisible){
			$clusterGroup=[];
			for(j=i-1; j>=0; j--){
				if(this._mapMarkers[j]._makeVisible && this._iconBounds[$mapZoomLevel][i].intersects(this._iconBounds[$mapZoomLevel][j])){
					$clusterGroup.push(j);
				}
			}
			if($clusterGroup.length!==0){
				$clusterGroup.push(i);
				for(j=$clusterGroup.length-1; j>=0; j--){
					this._mapMarkers[$clusterGroup[j]]._makeVisible=false;
				}
				this._clusterMarkers.push(this._clusterMarker($clusterGroup));
			}
		}
	}
};

ClusterMarker.prototype.fitMapToMarkers=function(){
	var $markers=this._mapMarkers, $markersBounds=new GLatLngBounds(), i;
	for(i=$markers.length-1; i>=0; i--){
		$markersBounds.extend($markers[i].getLatLng());
	}
	var $fitMapToMarkersZoom=this._map.getBoundsZoomLevel($markersBounds);
		
	if(this.fitMapMaxZoom && $fitMapToMarkersZoom>this.fitMapMaxZoom){
		$fitMapToMarkersZoom=this.fitMapMaxZoom;
	}
	this._map.setCenter($markersBounds.getCenter(), $fitMapToMarkersZoom);
	this.refresh();
};

ClusterMarker.prototype._mapTypeChanged=function(){
	this.refresh(true);
};

ClusterMarker.prototype._moveEnd=function(){
	if(!this._cancelMoveEnd){
		this.refresh();
	}else{
		this._cancelMoveEnd=false;
	}
};

ClusterMarker.prototype._preCacheIconBounds=function($indexes){
	var $mapProjection=this._map.getCurrentMapType().getProjection(), $mapZoomLevel=this._map.getZoom(), i, $marker, $iconSize, $iconAnchorPoint, $iconAnchorPointOffset, $iconBoundsPointSw, $iconBoundsPointNe, $iconBoundsLatLngSw, $iconBoundsLatLngNe, $intersectPadding=this.intersectPadding;
	for(i=$indexes.length-1; i>=0; i--){
		$marker=this._mapMarkers[$indexes[i]];
		$iconSize=$marker.getIcon().iconSize;
		$iconAnchorPoint=$mapProjection.fromLatLngToPixel($marker.getLatLng(), $mapZoomLevel);
		$iconAnchorPointOffset=$marker.getIcon().iconAnchor;
		$iconBoundsPointSw=new GPoint($iconAnchorPoint.x-$iconAnchorPointOffset.x-$intersectPadding, $iconAnchorPoint.y-$iconAnchorPointOffset.y+$iconSize.height+$intersectPadding);
		$iconBoundsPointNe=new GPoint($iconAnchorPoint.x-$iconAnchorPointOffset.x+$iconSize.width+$intersectPadding, $iconAnchorPoint.y-$iconAnchorPointOffset.y-$intersectPadding);
		$iconBoundsLatLngSw=$mapProjection.fromPixelToLatLng($iconBoundsPointSw, $mapZoomLevel);
		$iconBoundsLatLngNe=$mapProjection.fromPixelToLatLng($iconBoundsPointNe, $mapZoomLevel);
		this._iconBounds[$mapZoomLevel][$indexes[i]]=new GLatLngBounds($iconBoundsLatLngSw, $iconBoundsLatLngNe);
	}
};

ClusterMarker.prototype.refresh=function($forceFullRefresh){
	var i,$marker, $uncachedIconBoundsIndexes=this._filterActiveMapMarkers();
	//alert(map.getZoom());
	if(this._activeMarkersChanged || $forceFullRefresh){
		this._removeClusterMarkers();
		if(map.getZoom()<14) {
		if(this.clusteringEnabled && this._map.getZoom()<this._map.getCurrentMapType().getMaximumResolution()){
			if($uncachedIconBoundsIndexes.length>0){
				this._preCacheIconBounds($uncachedIconBoundsIndexes);
			}
			this._filterIntersectingMapMarkers();
		}
		}
		for(i=this._clusterMarkers.length-1; i>=0; i--){
			this._map.addOverlay(this._clusterMarkers[i]);
		}
		for(i=this._mapMarkers.length-1; i>=0; i--){
			$marker=this._mapMarkers[i];
			if(!$marker._isVisible && $marker._makeVisible){
				this._map.addOverlay($marker);
				$marker._isVisible=true;
			}
			if($marker._isVisible && !$marker._makeVisible){
				this._map.removeOverlay($marker);
				$marker._isVisible=false;
			}
		}
	}
};

ClusterMarker.prototype._removeClusterMarkers=function(){
	for(var i=this._clusterMarkers.length-1; i>=0; i--){
		this._map.removeOverlay(this._clusterMarkers[i]);
	}
	for(i=this._eventListeners.length-1; i>=0; i--){
		GEvent.removeListener(this._eventListeners[i]);
	}
	this._clusterMarkers=[];
	this._eventListeners=[];
};

ClusterMarker.prototype.removeMarkers=function(){
	for(var i=this._mapMarkers.length-1; i>=0; i--){
		if(this._mapMarkers[i]. _isVisible){
			this._map.removeOverlay(this._mapMarkers[i]);
		}
		delete this._mapMarkers[i]._isVisible;
		delete this._mapMarkers[i]._isActive;
		delete this._mapMarkers[i]._makeVisible;
	}
	this._removeClusterMarkers();
	this._mapMarkers=[];
	this._iconBounds=[];
};


ClusterMarker.prototype.triggerClick=function($index){
	var $marker=this._mapMarkers[$index];
	if($marker._isVisible){
		//	$marker is visible
		GEvent.trigger($marker, 'click');
	}
	else if($marker._isActive){
		//	$marker is clustered
		this._map.setCenter($marker.getLatLng());
		this._map.zoomIn();
		this.triggerClick($index);
	}else{
		// $marker is not within active area (map bounds + border padding)
		this._map.setCenter($marker.getLatLng());
		this.triggerClick($index);
	}
};

ClusterMarker.prototype._zoomEnd=function(){
	this._cancelMoveEnd=true;
	this.refresh(true);
};