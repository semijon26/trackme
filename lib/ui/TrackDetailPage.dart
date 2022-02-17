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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, right: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.totalDistance() != -1 ? track.totalDistance().toString() + "m" : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.brown),),
                            const Text('Distance'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, left: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.startTime != null ? dateFormatter.format(track.startTime!.toLocal()) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.brown),),
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
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, right: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.startTime != null ? dateFormatter.format(track.startTime!.toLocal()) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.brown),),
                            const Text('Start Time'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, left: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.startTime != null ? dateFormatter.format(track.startTime!.toLocal()) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.brown),),
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
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, right: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.startTime != null ? dateFormatter.format(track.startTime!.toLocal()) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.brown),),
                            const Text('Max Speed'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    width: 170,
                    child: Card(
                      margin: const EdgeInsets.only(top: 15, left: 7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text((track.startTime != null ? dateFormatter.format(track.startTime!.toLocal()) : 'unknown'),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.brown),),
                            const Text('Avg Speed'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }

  void _openMap() {
    // TODO (Map öffnen / Mehr Infos zur Route)
  }
}
