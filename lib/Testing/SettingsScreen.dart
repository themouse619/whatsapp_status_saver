import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:whatsapp_status_saver/Common/CustomWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_status_saver/Common/Constants.dart' as cnst;
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:whatsapp_status_saver/en.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool deleteOptionSwitch;
  String downloadLocationPath = '';

  Directory root;
  Future<List<FileSystemEntity>> future;

  @override
  void initState() {
    super.initState();
    getInitialDownloadPathValue();
    setRootDirectory();
    // getSwitch();
  }

  getInitialDownloadPathValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      downloadLocationPath = prefs.getString(cnst.Session.downloadPath);
    });
  }

  setRootDirectory() async {
    final rootDir = await getRootDir();
    root = Directory(rootDir);
    print("root.path");
    print(root.path);
  }

  Future<String> getRootDir() async {
    var externalDirectoryPath = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();
    // downloadLocationPath = externalDirectoryPath.path;
    if (externalDirectoryPath != null) {
      final subbed = externalDirectoryPath.path.replaceFirst(
        ANDROID_DATA_FREAKTEMPLATE_STATUSSAVER_FILES,
        '',
      );
      return subbed;
    }
    throw FAILED_TO_GET_EXTERNAL_STORAGE_DIRECTORY;
  }

  getSwitch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deleteOptionSwitch = prefs.getBool(cnst.Session.deleteSwitch.toString());
      print(deleteOptionSwitch);
    });
  }

  setSwitch(bool delSwitch) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(cnst.Session.deleteSwitch.toString(), delSwitch);
  }

  getDownloadPath() async {
    String path = await FilesystemPicker.open(
      title: DOWNLOAD_TO_LOCATION,
      context: context,
      rootDirectory: root,
      fsType: FilesystemType.folder,
      pickText: DOWNLOAD_FILES_TO_THIS_FOLDER,
      folderIconColor: Colors.indigo[600],
      requestPermission: () async =>
          await Permission.storage.request().isGranted,
    );
    if (path != null) {
      setState(() {
        downloadLocationPath = path;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(cnst.Session.downloadPath, downloadLocationPath);
      print(prefs.get(cnst.Session.downloadPath).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 6.0, top: 10, right: 6.0, bottom: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                SAVE_STATUSES_AT_PATH,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: cnst.appPrimaryMaterialColor,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  downloadLocationPath,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.indigo[500],
                      fontWeight: FontWeight.w600),
                ),
              ),
              onTap: () {
                getDownloadPath();
              },
            ),
            Divider(
              height: 10,
              color: Colors.indigo[200],
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            ListTile(
              title: Text(
                CLEAR_APP_CACHE,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: cnst.appPrimaryMaterialColor),
              ),
              subtitle: Text(
                CLEAR_TEMPORARY_CACHE_AND_JUNK_FILES_TO_SPEED_UP_APP,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[500]),
              ),
              onTap: () {
                print('clear cache clicked');
                Fluttertoast.showToast(
                    msg: CACHE_CLEARED_SUCCESSFULLY,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    backgroundColor:
                        cnst.appPrimaryMaterialColor.withOpacity(0.75),
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
            ),
            ListTile(
              title: Text(
                FEEDBACK,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: cnst.appPrimaryMaterialColor),
              ),
              subtitle: Text(
                LET_US_KNOW_IF_YOU_HAVE_ANY_SUGGESTIONS_OR_FOUND_BUGS,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[500]),
              ),
              onTap: () {
                print('Feedback clicked');
                Navigator.pushNamed(context, '/FeedbackScreen');
              },
            ),
            ListTile(
              title: Text(
                ABOUT,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: cnst.appPrimaryMaterialColor),
              ),
              subtitle: Text(
                VERSION,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[500]),
              ),
              onTap: () {
                print('version clicked');
              },
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                print('Rate Us clicked');
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RateUsPopUp();
                    });
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.star_rounded,
                    color: cnst.appPrimaryMaterialColor,
                    size: 23,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    RATE_US,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cnst.appPrimaryMaterialColor,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                print('Share It clicked');
                Share.share(
                    DOWNLOAD_THE_APP_FROM_HERE);
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.share_rounded,
                    color: cnst.appPrimaryMaterialColor,
                    size: 23,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    SHARE_IT,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cnst.appPrimaryMaterialColor,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
