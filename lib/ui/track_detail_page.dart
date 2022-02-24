import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:personal_tracking_app/ui/google_map_window.dart';
import 'package:personal_tracking_app/ui/line_chart_widget.dart';
import 'package:share_plus/share_plus.dart';

import '../gpx_export.dart';
import '../model/track.dart';
import '../value_format.dart';


class TrackDetailPage extends StatefulWidget {
  final Track track;

  const TrackDetailPage(this.track, {Key? key}) : super(key: key);

  @override
  State<TrackDetailPage> createState() {
    return _TrackDetailPageState();
  }
}


class _TrackDetailPageState extends State<TrackDetailPage> {

  @override
  Widget build(BuildContext context) {
    Track track = widget.track;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
              onPressed: () => _shareTrack(context, track),
              icon: const Icon(Icons.ios_share))
        ],
        title: Text(
          'Track from ' +
              (track.startTime != null
                  ? ValueFormat().dateFormatter.format(track.startTime!.toLocal())
                  : 'unknown'),
        ),
      ),
      body: Scrollbar(
        interactive: true,
        radius: const Radius.circular(2),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(7),
          children: [
            SizedBox(
              height: 430,
              child: GoogleMapWindow(track),
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
              child: LineChartWidget(track),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow_outlined),
              title: Text(
                "Start Time: " +
                    (track.startTime != null
                        ? ValueFormat().timeFormatter.format(track.startTime!.toLocal())
                        : 'unknown'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.stop_outlined),
              title: Text(
                "End Time: " +
                    (track.startTime != null
                        ? ValueFormat().timeFormatter.format(track.endTime!.toLocal())
                        : 'unknown'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.route_outlined),
              title: Text(
                "Distance: " +
                    (track.totalDistance != -1
                        ? ValueFormat().formatDistance(track.totalDistance)
                        : 'unknown'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(
                "Duration: " +
                    (ValueFormat().getDuration(track) != null
                        ? ValueFormat().getDuration(track)!
                        : 'unknown'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: Text(
                "Avg Speed: " +
                    ValueFormat().formatAndCheckSpeedValue(track.avgSpeed),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: Text(
                "Max Speed: " +
                    ValueFormat().formatAndCheckSpeedValue(track.maxSpeed),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: Text(
                "Min Altitude: " +
                    ValueFormat().formatAltitude(track.minAltitude),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: Text(
                "Max Altitude: " +
                    ValueFormat().formatAltitude(track.maxAltitude),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareTrack(BuildContext context, Track track) async {
    GpxExport _gpxExport = GpxExport(track);
    RenderBox? box = context.findRenderObject() as RenderBox;

    final path = await _gpxExport.writeXml();

    Share.shareFiles([path],
        subject: "My Track",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
