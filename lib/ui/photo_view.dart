import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart' as pv;
import 'package:gallery_saver/gallery_saver.dart';

import '../model/track.dart';

class PhotoView extends StatefulWidget {
  final String photoPath;
  final Track track;

  const PhotoView(this.track, this.photoPath, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewState();
  }
}

class _PhotoViewState extends State<PhotoView> {
  late Uint8List imageBytes;

  @override
  void initState() {
    super.initState();
    _convertImageToBytes().then((value) {
      setState(() {});
    });
  }

  Future<void> _convertImageToBytes() async {
    File imageFile = File(widget.photoPath);
    imageBytes = await imageFile.readAsBytes();
  }

  _showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Cancel"));

    Widget continueButton = TextButton(
        onPressed: () {
          _deleteImage();
        },
        child: const Text("Delete"));

    AlertDialog alert = AlertDialog(
      title: Text("Delete Photo?"),
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
    try {
      widget.track.removePhoto(widget.photoPath);
      widget.track.save();
      await File(widget.photoPath).delete();
      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 2;
      });
      return Fluttertoast.showToast(
          msg: "deleted",
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.indigo);
    } catch (e) {
      return Fluttertoast.showToast(
          msg: "could not delete",
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.indigo);
    }
  }

  _saveImage() async {
    bool? isSuccessful = await GallerySaver.saveImage(widget.photoPath);
    if (isSuccessful!) {
      return Fluttertoast.showToast(
          msg: "saved",
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.indigo);
    }
    return Fluttertoast.showToast(
        msg: "could not save",
        backgroundColor: Colors.grey.shade200,
        textColor: Colors.indigo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
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
          child: pv.PhotoView(imageProvider: MemoryImage(imageBytes)),
        ));
  }
}
