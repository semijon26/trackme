import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/geo_position.dart';
import '../model/track.dart';
import '../value_format.dart';

class GoogleMapWidget extends StatefulWidget {
  final Track track;
  final double height;

  const GoogleMapWidget(this.track, this.height, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GoogleMapWidgetState();
  }
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  late BitmapDescriptor _startMarkerIcon;
  late BitmapDescriptor _endMarkerIcon;

  _GoogleMapWidgetState();

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
    var t = AppLocalizations.of(context)!;
    Track track = widget.track;
    LatLng endPos =
        LatLng(track.positions.last.latitude!, track.positions.last.longitude!);
    LatLng startPos = LatLng(
        track.positions.first.latitude!, track.positions.first.longitude!);
    _markers.add(Marker(
      markerId: MarkerId(track.startTime.toString()),
      position: startPos,
      infoWindow: InfoWindow(
        title: ('${t.startedHereAt} ' +
            ValueFormat().timeFormatter.format(track.startTime!.toLocal())),
      ),
      icon: _startMarkerIcon,
    ));
    _markers.add(Marker(
        markerId: MarkerId(track.endTime.toString()),
        position: endPos,
        infoWindow: InfoWindow(
          title: ('${t.endedHereAt} ' +
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
    var allPos = widget.track.positions;
    var list = <LatLng>[];
    if (allPos.length < 30) {
      for (GeoPosition p in allPos) {
        list.add(LatLng(p.latitude!, p.longitude!));
      }
    } else {
      double divider = (allPos.length / 20);
      if (kDebugMode) {
        print ("Divider" + divider.toStringAsFixed(5));
      }
      for (int i = 0; i < 19; i++) {
        int index = (i*divider).truncate();
        GeoPosition p = allPos.elementAt(index);
        list.add(LatLng(p.latitude!, p.longitude!));
        if (kDebugMode) {
          print("Position bei $index");
        }
      }
      list.add(LatLng(allPos.last.latitude!, allPos.last.longitude!));
      if (kDebugMode) {
        print("Position bei ${allPos.indexOf(allPos.last)}");
      }
    }
    return list;
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
