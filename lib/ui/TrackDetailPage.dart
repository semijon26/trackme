import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../model/Track.dart';

class TrackDetailPage extends StatelessWidget {
  DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  DateFormat timeFormatter = DateFormat('h:mm a');
  final Track track;

  TrackDetailPage(this.track, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track from ' +
              (track.startTime != null
                  ? dateFormatter.format(track.startTime!.toLocal())
                  : 'unknown'),
        ),
      ),
      body: Center(
          child: Column(
        children: [
          Text("Track information ..."),

        ],
      )),
    );
  }

  void _openMap() {
    // TODO (Map öffnen / Mehr Infos zur Route)
  }
}
