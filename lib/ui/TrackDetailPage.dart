import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:intl/intl.dart';
import 'package:personal_tracking_app/model/GeoPosition.dart';
import 'package:personal_tracking_app/ui/main.dart';
import 'package:share_plus/share_plus.dart';
import '../GpxExport.dart';
import '../model/Track.dart';

DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
DateFormat timeFormatter = DateFormat('h:mm a');


class TrackDetailPage extends StatefulWidget {

  final Track track;

  const TrackDetailPage(this.track, {Key? key}) : super(key: key);


  @override
  State<TrackDetailPage> createState() {
    return _TrackDetailPage();
  }

}


class _TrackDetailPage extends State<TrackDetailPage> {

  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  late BitmapDescriptor _startMarkerIcon;
  late BitmapDescriptor _endMarkerIcon;

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

  @override
  Widget build(BuildContext context) {
    Track track = widget.track;
    GeoPosition middlePos = track.getPositionAt(track.positions.length ~/ 2);
    LatLng _center = LatLng(middlePos.latitude!, middlePos.longitude!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
              onPressed: () => _share(context, track),
              icon: const Icon(Icons.ios_share))
        ],
        title: Text(
          'Track from ' +
              (track.startTime != null
                  ? dateFormatter.format(track.startTime!.toLocal())
                  : 'unknown'),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 360,
            width: 360,
            margin: const EdgeInsets.only(bottom: 10),
            child: GoogleMap(
              polylines: _drawPolyline(),
              markers: _markers,
              compassEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 14.0,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 360,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: track.photos.length,
                  itemBuilder: (context, index) {
                    final photo = track.photos.elementAt(index);
                    return Container(
                      margin: const EdgeInsets.all(3),
                        width: 80,
                        height: 80,
                        child: Image.file(
                          File(photo),
                          fit: BoxFit.cover,
                        ));
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                width: 170,
                child: Card(
                  margin: const EdgeInsets.only(top: 5, right: 7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (track.totalDistance != -1
                              ? formatDistance(track.totalDistance)
                              : 'unknown'),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.indigo),
                        ),
                        const Text('Distance'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                width: 170,
                child: Card(
                  margin: const EdgeInsets.only(top: 5, left: 7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (getDuration(track) != null
                              ? getDuration(track)!
                              : 'unknown'),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.indigo),
                        ),
                        const Text('Duration'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                width: 170,
                child: Card(
                  margin: const EdgeInsets.only(top: 5, right: 7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (track.startTime != null
                              ? timeFormatter.format(track.startTime!.toLocal())
                              : 'unknown'),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.indigo),
                        ),
                        const Text('Start Time'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                width: 170,
                child: Card(
                  margin: const EdgeInsets.only(top: 5, left: 7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (track.startTime != null
                              ? timeFormatter.format(track.endTime!.toLocal())
                              : 'unknown'),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.indigo),
                        ),
                        const Text('End Time'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                width: 170,
                child: Card(
                  margin: const EdgeInsets.only(top: 5, right: 7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatAndCheckSpeedValue(track.maxSpeed),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.indigo),
                        ),
                        const Text('Max Speed'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                width: 170,
                child: Card(
                  margin: const EdgeInsets.only(top: 5, left: 7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatAndCheckSpeedValue(track.avgSpeed),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.indigo),
                        ),
                        const Text('Avg Speed'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  Future<void> _share(BuildContext context, Track track) async {
    GpxExport _gpxExport = GpxExport(track);
    //String message = "Share this track";
    RenderBox? box = context.findRenderObject() as RenderBox;

    final path = await _gpxExport.writeXml();

    Share.shareFiles([path], subject: "My Track",
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  String formatDistance(int distanceInMeters) {
    String s = "";
    if (distanceInMeters > 999) {
      double distanceInKilometers = distanceInMeters.toDouble();
      distanceInKilometers = distanceInKilometers / 1000;
      s = double.parse(distanceInKilometers.toStringAsFixed(2)).toString();
      s = '$s km';
    } else {
      s = '$distanceInMeters m';
    }
    return s;
  }

  String? getDuration (Track track) {
    DateTime? dtStart = track.startTime;
    DateTime? dtEnd = track.endTime;
    Duration duration;
    if (dtStart == null || dtEnd == null) {
      return null;
    }
    duration = dtEnd.difference(dtStart);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatAndCheckSpeedValue(double speedInMetersPerSec) {
    speedInMetersPerSec = speedInMetersPerSec * 3.6;
    String s = "";
    if (speedInMetersPerSec.isNaN || speedInMetersPerSec.isInfinite) {
      return "unknown";
    } else {
      num mod = pow(10.0, 2);
      s = ((speedInMetersPerSec * mod).round().toDouble() / mod).toString();
    }
    return '$s km/h';
  }

  Set<Polyline>_drawPolyline() {
    Track track = widget.track;
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
            timeFormatter.format(track.startTime!.toLocal())),
      ),
      icon: _startMarkerIcon,
    ));
    _markers.add(Marker(
        markerId: MarkerId(track.endTime.toString()),
        position: endPos,
        infoWindow: InfoWindow(
          title: ('Ended here at ' +
              timeFormatter.format(track.endTime!.toLocal())),
        ),
        icon: _endMarkerIcon));
  }

  void setCustomMarkerIcon() async {
    _startMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/markers/startMarker.png');
    _endMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/markers/endMarker.png');
  }
}
