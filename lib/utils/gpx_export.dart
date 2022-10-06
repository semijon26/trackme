import 'dart:io';
import 'package:gpx/gpx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_tracking_app/model/geo_position.dart';
import '../model/track.dart';

class GpxExport {
  final Track _track;

  GpxExport(this._track);

  Future<String> writeXml() async {
    final gpx = Gpx();
    gpx.version = '1.1';
    gpx.metadata = Metadata();
    gpx.metadata?.name = 'Track GPX File';
    gpx.metadata?.time = _track.startTime;
    gpx.creator = "dart-gpx library";

    List waypoints = gpx.wpts = [];
    for (GeoPosition pos in _track.positions) {
      waypoints
          .add(Wpt(lat: pos.latitude, lon: pos.longitude, time: pos.timestamp));
    }

    String gpxAsString = GpxWriter().asString(gpx, pretty: true);

    final path = await getTemporaryDirectory();

    String fullPath = "${path.path}/MyTrack.gpx";

    File file = File(fullPath);
    await file.writeAsString(gpxAsString);

    return fullPath;
  }
}
