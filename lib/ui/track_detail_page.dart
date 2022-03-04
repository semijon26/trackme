import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:personal_tracking_app/ui/google_map_widget.dart';
import 'package:personal_tracking_app/ui/line_chart_widget.dart';
import 'package:personal_tracking_app/ui/photo_fullscreen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _shareTrack(BuildContext context, Track track) async {
    GpxExport _gpxExport = GpxExport(track);
    RenderBox? box = context.findRenderObject() as RenderBox;

    final path = await _gpxExport.writeXml();

    Share.shareFiles([path],
        subject: "My Track",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  _changeName(Track track) async {
    var name = await _changeNameDialog(track);
    if (name == "") {
      name = null;
    }
    name != null ? track.name = name
        : track.name = track.name;
    track.save();
    setState(() => {});
  }

  Future<String?> _changeNameDialog(Track track) {
    var t = AppLocalizations.of(context)!;

    submit() {
      Navigator.of(context).pop(controller.text);
      controller.clear();
    }

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.submitNewTrackName),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: track.name != null ? track.name! : t.unknown),
          controller: controller,
          onSubmitted: (_) => submit(),
        ),
        actions: [
          TextButton(
            child: Text(t.submit),
            onPressed: submit,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    Track track = widget.track;
    double googleMapHeight = 430;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
          actions: [
            IconButton(
                onPressed: () => _changeName(track),
                icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: () => _shareTrack(context, track),
                icon: const Icon(Icons.ios_share))
          ],
          title: Text(track.name != null ? track.name! : t.unknown)
      ),
      body: Scrollbar(
        interactive: true,
        radius: const Radius.circular(2),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(7),
          children: [
            SizedBox(
              height: googleMapHeight,
              child: GoogleMapWidget(track, googleMapHeight),
            ),
            if(track.photos.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 5),
                child: Text(t.photos,
                    style: const TextStyle(
                        color: Colors.indigo,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 100,
                margin: const EdgeInsets.only(top: 5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: track.photos.length,
                  itemBuilder: (context, index) {
                    final photo = track.photos.elementAt(index);
                    return Container(
                        margin: const EdgeInsets.all(1),
                        width: 100,
                        height: 100,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PhotoFullscreen(widget.track, photo)))
                                .then((value) => setState(() {}));
                          },
                          child: Image.file(
                            File(photo),
                            fit: BoxFit.cover,
                          ),
                        ));
                  },
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 5),
              child: Text(t.altitudeChart,
                  style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 210,
              margin: const EdgeInsets.only(top: 5, right: 15),
              child: LineChartWidget(track),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 5),
              child: Text(t.details,
                  style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow_outlined),
              title: Text(
                "${t.startTime}: " +
                    (track.startTime != null
                        ? ValueFormat()
                            .timeFormatter
                            .format(track.startTime!.toLocal())
                        : t.unknown),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.stop_outlined),
              title: Text(
                "${t.endTime}: " +
                    (track.startTime != null
                        ? ValueFormat()
                            .timeFormatter
                            .format(track.endTime!.toLocal())
                        : t.unknown),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.route_outlined),
              title: Text(
                "${t.distance}: " +
                    (track.totalDistance != -1
                        ? ValueFormat().formatDistance(track.totalDistance)
                        : t.unknown),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(
                "${t.duration}: " +
                    (ValueFormat().getDuration(track) != null
                        ? ValueFormat().getDuration(track)!
                        : t.unknown),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: Text(
                "${t.avgSpeed}: " +
                    ValueFormat().formatAndCheckSpeedValue(track.avgSpeed),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: Text(
                "${t.maxSpeed}: " +
                    ValueFormat().formatAndCheckSpeedValue(track.maxSpeed),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: Text(
                "${t.minAltitude}: " +
                    ValueFormat().formatAltitude(track.minAltitude),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: Text(
                "${t.maxAltitude}: " +
                    ValueFormat().formatAltitude(track.maxAltitude),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
