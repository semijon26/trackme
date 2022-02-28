import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/geo_position.dart';
import '../model/track.dart';
import '../value_format.dart';

class GoogleMapWindow extends StatefulWidget {
  final Track track;
  final double height;

  const GoogleMapWindow(this.track, this.height, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GoogleMapWindowState();
  }
}

class _GoogleMapWindowState extends State<GoogleMapWindow> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  late BitmapDescriptor _startMarkerIcon;
  late BitmapDescriptor _endMarkerIcon;

  _GoogleMapWindowState();

  @override
  void initState() {
    super.initState();
    setCustomMarkerIcon();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _createMarkers();
    });
  }

  Set<Polyline> _drawPolyline() {
    Set<Polyline> polylines = {};
    var latLngSegment = <LatLng>[];

    for (GeoPosition pos in widget.track.positions) {
      LatLng latLngPos = LatLng(pos.latitude!, pos.longitude!);
      latLngSegment.add(latLngPos);
    }

    polylines.add(Polyline(
      polylineId: PolylineId(widget.track.startTime.toString()),
      visible: true,
      color: Colors.indigo,
      points: latLngSegment,
      width: 8,
    ));
    return polylines;
  }

  _createMarkers() {
    Track track = widget.track;
    LatLng endPos =
        LatLng(track.positions.last.latitude!, track.positions.last.longitude!);
    LatLng startPos = LatLng(
        track.positions.first.latitude!, track.positions.first.longitude!);
    _markers.add(Marker(
      markerId: MarkerId(track.startTime.toString()),
      position: startPos,
      infoWindow: InfoWindow(
        title: ('Started here at ' +
            ValueFormat().timeFormatter.format(track.startTime!.toLocal())),
      ),
      icon: _startMarkerIcon,
    ));
    _markers.add(Marker(
        markerId: MarkerId(track.endTime.toString()),
        position: endPos,
        infoWindow: InfoWindow(
          title: ('Ended here at ' +
              ValueFormat().timeFormatter.format(track.endTime!.toLocal())),
        ),
        icon: _endMarkerIcon));
  }

  void setCustomMarkerIcon() async {
    _startMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/markers/startMarker.png');
    _endMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/markers/endMarker.png');
  }

  CameraPosition _getCameraPosition() {
    var center = _getCenter();

    if (center != null) {
      return CameraPosition(
        target: center,
        zoom: _getBoundsZoomLevel(
            _getLatLngList(), Size(widget.height, widget.height)),
      );
    } else {
      return CameraPosition(
        target: LatLng(widget.track.positions.first.latitude!, widget.track.positions.first.longitude!),
        zoom: 14,
      );
    }
  }

  LatLng? _getCenter() {
    List<LatLng> positions = _getLatLngList();
    if(positions.isNotEmpty) {
      var bounds = _getLatLngBounds(positions);
      return LatLng((bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2);
    } else {
      return null;
    }
  }

  List<LatLng> _getLatLngList() {
    var positions = <LatLng>[];
    GeoPosition pos1 = widget.track.positions.first;
    GeoPosition pos2 = widget.track.positions.last;
    positions.add(LatLng(pos1.latitude!, pos1.longitude!));
    positions.add(LatLng(pos2.latitude!, pos2.longitude!));
    return positions;
  }

  LatLngBounds _getLatLngBounds (List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (var latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(x0!, y0!), northeast: LatLng(x1!, y1!));
  }

  double _getBoundsZoomLevel(List<LatLng> positions, Size mapDimensions) {
    if (positions.length <= 1) {
      return 14;
    }
    var bounds = _getLatLngBounds(positions);

    var mapMargin = 100;
    var totalMapDimension =
    Size(mapDimensions.width + mapMargin, mapDimensions.height + mapMargin);

    double latRad(lat) {
      var sinValue = sin(lat * pi / 180);
      var radX2 = log((1 + sinValue) / (1 - sinValue)) / 2;
      return max(min(radX2, pi), -pi) / 2;
    }

    double zoom(mapPx, worldPx, fraction) {
      return (log(mapPx / worldPx / fraction) / ln2).floorToDouble();
    }

    var ne = bounds.northeast;
    var sw = bounds.southwest;

    var latFraction = (latRad(ne.latitude) - latRad(sw.latitude)) / pi;

    var lngDiff = ne.longitude - sw.longitude;
    var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

    var latZoom =
    zoom(mapDimensions.height, totalMapDimension.height, latFraction);
    var lngZoom =
    zoom(mapDimensions.width, totalMapDimension.width, lngFraction);

    if (latZoom < 0) return lngZoom;
    if (lngZoom < 0) return latZoom;

    return min(latZoom, lngZoom);
  }

  @override
  Widget build(BuildContext context) {
    Track track = widget.track;
    GeoPosition middlePos = track.getPositionAt(track.positions.length ~/ 2);
    LatLng _center = LatLng(middlePos.latitude!, middlePos.longitude!);

    return GoogleMap(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
      polylines: _drawPolyline(),
      markers: _markers,
      compassEnabled: true,
      onMapCreated: _onMapCreated,
      initialCameraPosition: _getCameraPosition(),
    );
  }
}
