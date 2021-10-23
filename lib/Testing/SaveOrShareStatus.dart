import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_status_saver/Testing/SavedStatusesScreen.dart';
import 'package:whatsapp_status_saver/en.dart';

class SaveOrShareStatus extends StatefulWidget {
  String path;
  bool showSave;

  SaveOrShareStatus(this.path, {this.showSave = true});

  @override
  _SaveOrShareStatusState createState() => _SaveOrShareStatusState();
}

class _SaveOrShareStatusState extends State<SaveOrShareStatus> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  SnackBar snackBar;

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.

  @override
  void initState() {
    super.initState();
    chkIfVideo();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: widget.path.endsWith(".mp4")
                    ? chewieController == null
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Chewie(
                            controller: chewieController,
                          )
                    : Image.file(
                        File(
                          widget.path,
                        ),
                      ),
              ),
            ),
            // SizedBox(
            //   height: 50,
            // ),
            // Row(
            //   mainAxisAlignment: widget.showSave ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
            //   children: [
            //     Container(
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         color: Colors.blue,
            //       ),
            //       child: IconButton(
            //           onPressed: (){
            //             Share.shareFiles(['${widget.path}'], text: 'shared via WHATSAPP STATUS SAVER');
            //           },
            //           icon: Icon(Icons.share, color: Colors.white,),
            //       ),
            //     ),
            //     widget.showSave ? Container(
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         color: Colors.blue,
            //       ),
            //       child: IconButton(
            //           onPressed: () async{
            //             await createAndSaveFile();
            //           },
            //         color: Colors.white,
            //           icon: Icon(Icons.save),
            //       ),
            //     ) : SizedBox(),
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  createAndSaveFile() async {
    final path = Platform.isIOS
        ? await getDownloadsDirectory()
        : await getExternalStorageDirectory();
    File f = File(path.path + "/" + widget.path.split("/").last);
    print(f.path);
    await f.create();
    f.writeAsBytes(File(widget.path).readAsBytesSync());
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print("FILE SAVED SUCCESSFULLY : " + f.path);
  }

  void chkIfVideo() async {
    snackBar = SnackBar(
      content: Text(STATUS_SAVED_SUCCESSFULLY),
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: GO_TO_DOWNLOADS,
        textColor: Colors.blue,
        onPressed: () {
          openSavedStatusScreen();
        },
      ),
    );

    if (widget.path.endsWith(".mp4")) {
      videoPlayerController = VideoPlayerController.file(File(widget.path));
      await videoPlayerController.initialize();

      setState(() {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          looping: true,
        );
      });
    }
  }

  void openSavedStatusScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SavedStatusesScreen()));
  }
}
