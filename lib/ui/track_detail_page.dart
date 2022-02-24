import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:personal_tracking_app/model/geo_position.dart';
import 'package:share_plus/share_plus.dart';

import '../gpx_export.dart';
import '../model/track.dart';

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
  final Set<Marker> _markers = {};
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
      body: Scrollbar(
        interactive: true,
        radius: const Radius.circular(2),
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(7),
          children: [
            SizedBox(
              height: 430,
              child: GoogleMap(
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
              ),
            ),
            Container(
              height: 100,
              margin: const EdgeInsets.only(top: 5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: track.photos.length,
                itemBuilder: (context, index) {
                  final photo = track.photos.elementAt(index);
                  return Container(
                      margin: const EdgeInsets.all(1),
                      width: 100,
                      height: 100,
                      child: Image.file(
                        File(photo),
                        fit: BoxFit.cover,
                      ));
                },
              ),
            ),
            Container(
              height: 170,
              margin: const EdgeInsets.only(top: 5),
              //color: Colors.white,
              child: _buildChart(context),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow_outlined),
              title: Text(
                "Start Time: " +
                    (track.startTime != null
                        ? timeFormatter.format(track.startTime!.toLocal())
                        : 'unknown'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.stop_outlined),
              title: Text(
                "End Time: " +
                    (track.startTime != null
                        ? timeFormatter.format(track.endTime!.toLocal())
                        : 'unknown'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.route_outlined),
              title: Text(
                "Distance: " +
                    (track.totalDistance != -1
                        ? formatDistance(track.totalDistance)
                        : 'unknown'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(
                "Duration: " +
                    (getDuration(track) != null
                        ? getDuration(track)!
                        : 'unknown'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: Text(
                "Avg Speed: " + _formatAndCheckSpeedValue(track.avgSpeed),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: Text(
                "Max Speed: " + _formatAndCheckSpeedValue(track.maxSpeed),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: Text(
                "Min Altitude: " + _formatAltitude(track.minAltitude),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: Text(
                "Max Altitude: " + _formatAltitude(track.maxAltitude),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
     Track track = widget.track;
     const List<Color> gradientColors = [
       Colors.indigo, Color.fromRGBO(204, 0, 0, 100)
     ];
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(showTitles: false),
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(
            showTitles: true,
            reservedSize: 14,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
          )
        ),
        axisTitleData: FlAxisTitleData(
          leftTitle: AxisTitle(
            showTitle: true,
            margin: 0,
            titleText: "altitude in meters",
            textAlign: TextAlign.center
          ),
          topTitle: AxisTitle(
            showTitle: true,
            margin: 0,
            titleText: "distance in meters",
            textAlign: TextAlign.center
          )
        ),
        minX: 0,
        maxX: track.totalDistance.toDouble(),
        minY: track.minAltitude,
        maxY: track.maxAltitude,
        gridData: FlGridData(
          show: true,
        ),
        lineBarsData: [
          LineChartBarData(
              spots: _getSpotsList(track),
            isCurved: true,
            preventCurveOvershootingThreshold: 20,
            colors: gradientColors,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: gradientColors.map((color) => color.withOpacity(0.2)).toList(),
            )
          )
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.indigo.withOpacity(.2),
            /*getTooltipItems: (List<LineBarSpot> touchedBarSpots) {

            }*/
          )
        )
      )
    );
  }

  List<FlSpot> _getSpotsList (Track track) {
     var spots = <FlSpot>[];
     for (int i = 0; i < track.positions.length; i++) {
       GeoPosition currentPos = track.positions.elementAt(i);
       spots.add(FlSpot(track.calcDistanceAt(i), currentPos.altitude!));
       print("getSpotsList: ${track.calcDistanceAt(i)} - ${currentPos.altitude!}");
     }
     return spots;
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

  String _formatAltitude(double altitude) {
    return "${altitude.round().toString()} m";
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
