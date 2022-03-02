import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart' as pv;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/track.dart';

class PhotoFullscreen extends StatefulWidget {
  final String photoPath;
  final Track track;

  const PhotoFullscreen(this.track, this.photoPath, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PhotoFullscreenState();
  }
}

class _PhotoFullscreenState extends State<PhotoFullscreen> {

  _showAlertDialog(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(t.cancel));

    Widget continueButton = TextButton(
        onPressed: () {
          _deleteImage();
        },
        child: Text(t.delete));

    AlertDialog alert = AlertDialog(
      title: Text(t.deletePhotoQuestion),
      actions: [cancelButton, continueButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _deleteImage() async {
    var t = AppLocalizations.of(context)!;
    try {
      widget.track.removePhoto(widget.photoPath);
      widget.track.save();
      await File(widget.photoPath).delete();
      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 2;
      });
      return Fluttertoast.showToast(
          msg: t.deletedToastMsg,
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.indigo);
    } catch (e) {
      return Fluttertoast.showToast(
          msg: t.couldntDeleteToastMsg,
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.indigo);
    }
  }

  _saveImage() async {
    var t = AppLocalizations.of(context)!;
    bool? isSuccessful = await GallerySaver.saveImage(widget.photoPath);
    if (isSuccessful!) {
      return Fluttertoast.showToast(
          msg: t.savedToastMsg,
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.indigo);
    }
    return Fluttertoast.showToast(
        msg: t.couldntSaveToastMsg,
        backgroundColor: Colors.grey.shade200,
        textColor: Colors.indigo);
  }

  Future<void> _sharePhoto(BuildContext context, String photoPath) async {
    RenderBox? box = context.findRenderObject() as RenderBox;
    Share.shareFiles([photoPath],
        subject: "Track Photo",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () {
                  _sharePhoto(context, widget.photoPath);
                },
                icon: const Icon(Icons.ios_share)),
            IconButton(
                onPressed: () {
                  _saveImage();
                },
                icon: const Icon(Icons.save_alt)),
            IconButton(
              onPressed: () {
                _showAlertDialog(context);
              },
              icon: const Icon(Icons.delete),
              color: Colors.red,
            )
          ],
        ),
        body: Container(
            color: Colors.black,
            child: pv.PhotoView(
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 4,
              imageProvider: FileImage(File(widget.photoPath)),
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
                  ),
                ),
              ),
            )));
  }
}
