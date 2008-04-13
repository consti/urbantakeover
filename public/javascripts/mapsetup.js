var map, cluster;

function mapini() {
	if (GBrowserIsCompatible()) {
		map=new GMap2(document.getElementById('map'));
		map.setCenter(new GLatLng(0, 0), 0, G_NORMAL_MAP);

		map.addControl(new GMapTypeControl());
		map.addControl(new GLargeMapControl());

		map.hideControls();
	
		map.enableScrollWheelZoom();
		new GKeyboardHandler(map);		
		
		var baseIcon = new GIcon();
		baseIcon.iconSize = new GSize(30, 32);
		baseIcon.iconAnchor = new GPoint(9, 32);
		baseIcon.infoWindowAnchor = new GPoint(20, 2);
		baseIcon.infoShadowAnchor = new GPoint(20, 32);
		
		var marker, markersArray=[];
		
		for (var i=0; i<json.length; i++) {
			if(json[i][2][0]) {
			marker=newMarker(new GLatLng(json[i][4], json[i][5]), json[i][0], json[i][1], json[i][2], json[i][3], baseIcon);
			markersArray.push(marker);
			}
		}

		GEvent.addListener(map, "mouseover", function(){
		map.showControls();
		});

		GEvent.addListener(map, "mouseout", function(){
		map.hideControls(); 
		});

		cluster=new ClusterMarker(map, { markers:markersArray } );
		cluster.fitMapToMarkers();

		map.savePosition();
	}
}



function drawArea(center,liColor,fillColor){
	var radius = 0.1; // 100 Meter
	var nodes = 10; // 40 x Sides
	var liWidth = 0; // Width of border
	var liOpa = 0.7; // Opacity of border
	var fillOpa = 0.7; // Opacity of fill
	var latConv = center.distanceFrom(new GLatLng(center.lat()+0.1, center.lng()))/100;
	var lngConv = center.distanceFrom(new GLatLng(center.lat(), center.lng()+0.1))/100;

	var points = [];
	var step = parseInt(360/nodes)||10;
	for(var i=0; i<=360; i+=step)
	{
	var pint = new GLatLng(center.lat() + (radius/latConv * Math.cos(i * Math.PI/180)), center.lng() + 
	(radius/lngConv * Math.sin(i * Math.PI/180)));
	points.push(pint);
	}
	var fillCol = fillColor || liColor || "#FFFFFF";
	var liCol = liColor || fillColor || "#FFFFFF";
	var poly = new GPolygon(points,liCol,liWidth,liOpa,fillCol,fillOpa);
	map.addOverlay(poly);
}


function newMarker(markerLocation, spotId, addr, users, mrkclr, baseIcon) {
	var utoicon = new GIcon(baseIcon);
	drawArea(markerLocation,users[0][1],users[0][2]);
	utoicon.image = "images/marker/"+mrkclr+".png";
	var marker=new GMarker(markerLocation, {icon: utoicon, title:'Spot['+spotId+']'});
	var infoMsg='<a href=\"/spot/'+spotId+'\" class=\"spot-name\">'+spotId+'</a><br/><span class=\"address\">'+addr+'</span><br/>current: <a href=\"/user/'+users[0][0]+'\" class=\"user-name\" style=\"background-color:#'+users[0][1]+';border-color:#'+users[0][2]+';\">'+users[0][0]+'</a><br/>';
		infoMsg+='here: <a href\"/user/'+users[0][0]+'" class=\"user-name\" style=\"background-color:#'+users[0][1]+';border-color:#'+users[0][2]+';\">'+users[0][0]+'</a>';
		for(var i=1;i<users.length; i++) {
			infoMsg+=', <a href\"/user/'+users[i][0]+'" class=\"user-name\" style=\"background-color:#'+users[i][1]+';border-color:#'+users[i][2]+';\">'+users[i][0]+'</a>';
		}
		infoMsg+='<br/><a href=\"http://flickr.com/photos/tags/'+spotId+'\">Tag on flickr</a>';
	GEvent.addListener(marker, 'click', function() {
		marker.openInfoWindowHtml(infoMsg);
	});
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
		this.clusterMarkerIcon.iconSize=new GSize(37, 41);
		this.clusterMarkerIcon.iconAnchor=new GPoint(14, 38);
		this.clusterMarkerIcon.infoWindowAnchor=new GPoint(14, 38);
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
	if(this._activeMarkersChanged || $forceFullRefresh){
		this._removeClusterMarkers();
		if(this.clusteringEnabled && this._map.getZoom()<this._map.getCurrentMapType().getMaximumResolution()){
			if($uncachedIconBoundsIndexes.length>0){
				this._preCacheIconBounds($uncachedIconBoundsIndexes);
			}
			this._filterIntersectingMapMarkers();
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


