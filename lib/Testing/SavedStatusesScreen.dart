import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsapp_status_saver/Testing/SaveOrShareStatus.dart';
import 'package:whatsapp_status_saver/en.dart';

class SavedStatusesScreen extends StatefulWidget {
  const SavedStatusesScreen({Key key}) : super(key: key);

  @override
  _SavedStatusesScreenState createState() => _SavedStatusesScreenState();
}

class _SavedStatusesScreenState extends State<SavedStatusesScreen> {
  Future<List<FileSystemEntity>> future;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    askForStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Downloaded Statuses"),
      // ),
      body: FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(8),
                itemCount: snapshot.data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1,
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 190,
                ),
                itemBuilder: (context, index) {
                  if (snapshot.data[index].path.endsWith(".jpg")) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SaveOrShareStatus(
                                      snapshot.data[index].path,
                                      showSave: false,
                                    )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 1.5,
                                spreadRadius: 1.0),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            File(
                              snapshot.data[index].path,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.data[index].path.endsWith(".mp4")) {
                    return FutureBuilder(
                        future: videoTothumb(path: snapshot.data[index].path),
                        builder: (context, AsyncSnapshot<Uint8List> snapshot2) {
                          if (snapshot2.hasData) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SaveOrShareStatus(
                                              snapshot.data[index].path,
                                              showSave: false,
                                            )));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 1.5,
                                        spreadRadius: 1.0),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(
                                        snapshot2.data,
                                        fit: BoxFit.cover,
                                      ),
                                      Center(
                                        child: Image.asset(
                                          'assets/play.png',
                                          height: 40,
                                          width: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (snapshot2.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        });
                  } else {
                    return SizedBox();
                  }
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  askForStoragePermission() async {
    PermissionStatus s = await Permission.storage.request();
    if (s.isGranted) {
      setState(() {
        future = readAllStatuses();
      });
    }
  }

  Future<Uint8List> videoTothumb({path}) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return uint8list;
  }

  Future<List<FileSystemEntity>> readAllStatuses() async {
    final rootDir = await getRootDir();
    final statusesPath = rootDir;
    // print(statusesPath);
    final dir = Directory(statusesPath);
    List<FileSystemEntity> files = dir.listSync();
    print(files.length);
    List<FileSystemEntity> files2 = [];
    for (File f in files) {
      print(f.path);
      if (f.path.endsWith(".jpg") || f.path.endsWith(".mp4")) {
        files2.add(File(f.path));
      }
    }

    return files2;
  }

  Future<String> getRootDir() async {
    var externalDirectoryPath = Platform.isIOS
        ? await getDownloadsDirectory()
        : await getExternalStorageDirectory();
    if (externalDirectoryPath != null) {
      final subbed = externalDirectoryPath.path;
      return subbed;
    }
    throw FAILED_TO_GET_EXTERNAL_STORAGE_DIRECTORY;
  }
}
