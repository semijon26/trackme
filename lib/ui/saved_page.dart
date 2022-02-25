import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_tracking_app/ui/track_detail_page.dart';

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

  _showAlertDialog(BuildContext context, Track track) {
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Cancel"));

    Widget confirmButton = TextButton(
        onPressed: () {
          track.removeWithPhotos();
          Navigator.pop(context);
        },
        child: const Text("Delete"));

    AlertDialog alert = AlertDialog(
      title: const Text("Delete Track?"),
      content: const Text("This track will be deleted with all its information and photos."),
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
    return WatchBoxBuilder(
        box: Hive.box('tracks'),
        builder: (context, tracksBox) {
          return ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: tracksBox.length,
            itemBuilder: (context, index) {
              final track = tracksBox.getAt(index) as Track;
              return Card(
                  child: Slidable(
                closeOnScroll: true,
                dragStartBehavior: DragStartBehavior.start,
                endActionPane: ActionPane(
                  extentRatio: .35,
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context){_showAlertDialog(context, track);},
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Track from ' +
                          (track.startTime != null
                              ? ValueFormat()
                                  .dateFormatter
                                  .format(track.startTime!.toLocal())
                              : 'unknown'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  minVerticalPadding: 10,
                  contentPadding: const EdgeInsets.only(
                      left: 16, right: 16, top: 7, bottom: 7),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('Start Time: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(track.startTime != null
                              ? ValueFormat()
                                  .timeFormatter
                                  .format(track.startTime!.toLocal())
                              : 'unknown'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('End Time: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(track.endTime != null
                              ? ValueFormat()
                                  .timeFormatter
                                  .format(track.endTime!.toLocal())
                              : 'unknown'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Max. Speed: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(ValueFormat()
                              .formatAndCheckSpeedValue(track.maxSpeed)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Avg. Speed: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(ValueFormat()
                              .formatAndCheckSpeedValue(track.avgSpeed)),
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
