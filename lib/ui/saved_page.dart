import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_tracking_app/ui/track_detail_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/track.dart';
import '../value_format.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage>
    with AutomaticKeepAliveClientMixin<SavedPage> {
  @override
  bool get wantKeepAlive => true;

  // Funktioniert nicht------------------------
  _showAlertDialog(Track track) {
    var t = AppLocalizations.of(context)!;
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(t.cancel));

    Widget confirmButton = TextButton(
        onPressed: () {
          track.removeWithPhotos();
          Navigator.of(context).pop();
        },
        child: Text(t.delete));

    AlertDialog alert = AlertDialog(
      title: Text(t.deleteTrackQuestion),
      content: Text(t.onDeleteDescription),
      actions: [cancelButton, confirmButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box('tracks').listenable(),
        builder: (BuildContext context, Box tracks, Widget? child) {
          return ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks.getAt(index) as Track;
              return Card(
                  child: Slidable(
                    closeOnScroll: true,
                    dragStartBehavior: DragStartBehavior.start,
                    endActionPane: ActionPane(
                      extentRatio: .35,
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _showAlertDialog(track),
                          //onPressed: (context) {track.delete();},
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: t.delete,
                        ),
                      ],
                    ),
                    child: ListTile(
                      isThreeLine: true,
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          track.name != null ? track.name! : t.unknown,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.only(
                          left: 16, right: 16, top: 7, bottom: 7),
                      subtitle: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("${t.from} ${ValueFormat().dateFormatter.format(track.startTime!)}"),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 35),
                                child: Column(
                                  children: [
                                    const Icon(Icons.play_arrow_outlined),
                                    Text(track.startTime != null
                                        ? ValueFormat()
                                        .timeFormatter
                                        .format(track.startTime!.toLocal())
                                        : t.unknown),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 35),
                                child: Column(
                                  children: [
                                    const Icon(Icons.stop_outlined),
                                    Text(track.endTime != null
                                        ? ValueFormat()
                                        .timeFormatter
                                        .format(track.endTime!.toLocal())
                                        : t.unknown),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 35),
                                child: Column(
                                  children: [
                                    const Icon(Icons.route_outlined),
                                    Text(track.totalDistance != -1
                                        ? ValueFormat().formatDistance(track.totalDistance)
                                        : t.unknown)
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.speed),
                                  Text(ValueFormat().formatAndCheckSpeedValue(track.avgSpeed)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TrackDetailPage(track)));
                      },
                    ),
                  ));
            },
          );
    });
  }
}
