import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/geo_position.dart';
import '../model/track.dart';
import '../value_format.dart';

class GoogleMapWindow extends StatefulWidget{

  final Track track;


  const GoogleMapWindow(this.track, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GoogleMapWindowState(track);
  }
}


class _GoogleMapWindowState extends State<GoogleMapWindow> {
  Track track;
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  late BitmapDescriptor _startMarkerIcon;
  late BitmapDescriptor _endMarkerIcon;

  _GoogleMapWindowState(this.track);

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

    for (GeoPosition pos in track.positions) {
      LatLng latLngPos = LatLng(pos.latitude!, pos.longitude!);
      latLngSegment.add(latLngPos);
    }

    polylines.add(Polyline(
      polylineId: PolylineId(track.startTime.toString()),
      visible: true,
      color: Colors.indigo,
      points: latLngSegment,
      width: 8,
    ));
    return polylines;
  }

  _createMarkers() {
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

  @override
  Widget build(BuildContext context) {
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
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 14.0,
      ),
    );
  }

}