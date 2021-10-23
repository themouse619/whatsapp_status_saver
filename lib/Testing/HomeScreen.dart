import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsapp_status_saver/Testing/SaveOrShareStatus.dart';
import 'package:whatsapp_status_saver/admob_service.dart';
import 'package:whatsapp_status_saver/en.dart';
import 'package:whatsapp_status_saver/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_status_saver/Common/Constants.dart' as cnst;

class HomeScreen extends StatefulWidget {
  String filterOption;

  HomeScreen({
    this.filterOption,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool deleteSwitch;
  Future<List<FileSystemEntity>> future;
  String downloadLocationPath;
  bool isWhatsApp;
  bool isWhatsAppBusiness;
  InterstitialAd _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
int downloadCount=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createInterstitialAd();
    askForStoragePermission();
    getDownloadPath();
  }

  setDownloadPath() async {
    final path = Platform.isIOS
        ? await getDownloadsDirectory()
        : await getExternalStorageDirectory();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(cnst.Session.downloadPath, path.path);
    await prefs.setBool(cnst.Session.downloadPathSet.toString(), true);
  }

  getDownloadPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(cnst.Session.downloadPathSet.toString()) != true) {
      setDownloadPath();
    }
    setState(() {
      downloadLocationPath = prefs.getString(cnst.Session.downloadPath);
      print("downloadLocationPath Home");
      print(downloadLocationPath);
    });
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: interstitial_Ad_Id,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            // _interstitialAd.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.filterOption);
    return Scaffold(
      body: FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
            if (snapshot.hasData) {
              return StaggeredGridView.countBuilder(
                padding: EdgeInsets.all(8),
                crossAxisCount: 2,
                itemCount: snapshot.data.length,
                staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                itemBuilder: (context, index) {
                  if (widget.filterOption == ALL_MEDIA) {
                    if (snapshot.data[index].path.endsWith(".jpg")) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SaveOrShareStatus(
                                      snapshot.data[index].path)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1.5,
                                  spreadRadius: 1.0),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                height: index % 2 == 0 ? 230 : 130,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      File(
                                        snapshot.data[index].path,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                print('download clicked');
                                                await createAndSaveFile(
                                                    snapshot.data[index].path);
                                                setState(() {
                                                  downloadCount++;
                                                  if(downloadCount>2){
                                                    _showInterstitialAd();
                                                    downloadCount=0;
                                                  }
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Image.asset(
                                                  'assets/download.png',
                                                  height: 40,
                                                  width: 40,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                print('share clicked');
                                                Share.shareFiles([
                                                  '${snapshot.data[index].path}'
                                                ],
                                                    text:
                                                        SHARED_VIA_WHATSAPP_STATUS_SAVER);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Image.asset(
                                                  'assets/more.png',
                                                  height: 40,
                                                  width: 40,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.data[index].path.endsWith(".mp4")) {
                      return FutureBuilder(
                          future: videoTothumb(path: snapshot.data[index].path),
                          builder:
                              (context, AsyncSnapshot<Uint8List> snapshot2) {
                            if (snapshot2.hasData) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SaveOrShareStatus(
                                                  snapshot.data[index].path)));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 1.5,
                                            spreadRadius: 1.0),
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        height: index % 2 == 0 ? 230 : 130,
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
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        print(
                                                            'download clicked');
                                                        await createAndSaveFile(
                                                            snapshot.data[index]
                                                                .path);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10.0),
                                                        child: Image.asset(
                                                          'assets/download.png',
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        print('share clicked');
                                                        Share.shareFiles([
                                                          '${snapshot.data[index].path}'
                                                        ],
                                                            text:
                                                                SHARED_VIA_WHATSAPP_STATUS_SAVER);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 10.0),
                                                        child: Image.asset(
                                                          'assets/more.png',
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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
                  } else if (widget.filterOption == IMAGES) {
                    if (snapshot.data[index].path.endsWith(".jpg")) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SaveOrShareStatus(
                                      snapshot.data[index].path)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1.5,
                                  spreadRadius: 1.0),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                height: index % 2 == 0 ? 230 : 130,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      File(
                                        snapshot.data[index].path,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                print('download clicked');
                                                await createAndSaveFile(
                                                    snapshot.data[index].path);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Image.asset(
                                                  'assets/download.png',
                                                  height: 40,
                                                  width: 40,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                print('share clicked');
                                                Share.shareFiles([
                                                  '${snapshot.data[index].path}'
                                                ],
                                                    text:
                                                        SHARED_VIA_WHATSAPP_STATUS_SAVER);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Image.asset(
                                                  'assets/more.png',
                                                  height: 40,
                                                  width: 40,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  } else {
                    if (snapshot.data[index].path.endsWith(".mp4")) {
                      return FutureBuilder(
                          future: videoTothumb(path: snapshot.data[index].path),
                          builder:
                              (context, AsyncSnapshot<Uint8List> snapshot2) {
                            if (snapshot2.hasData) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SaveOrShareStatus(
                                                  snapshot.data[index].path)));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 1.5,
                                            spreadRadius: 1.0),
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        height: index % 2 == 0 ? 230 : 130,
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
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        print(
                                                            'download clicked');
                                                        await createAndSaveFile(
                                                            snapshot.data[index]
                                                                .path);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10.0),
                                                        child: Image.asset(
                                                          'assets/download.png',
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        print('share clicked');
                                                        Share.shareFiles([
                                                          '${snapshot.data[index].path}'
                                                        ],
                                                            text:
                                                                SHARED_VIA_WHATSAPP_STATUS_SAVER);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 10.0),
                                                        child: Image.asset(
                                                          'assets/more.png',
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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
                  }
                },
              );
            }
            if (snapshot.hasError) {
              // print("error");
              // print(snapshot.error);
              return Center(
                child: Text(
                  DIRECTORY_NOT_FOUND,
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      bottomNavigationBar: Container(
        height: 50,
        child: AdWidget(
          key: UniqueKey(),
          ad: AdMobService.createBannerAd()..load(),
        ),
      ),
    );
  }

  askForStoragePermission() async {
    PermissionStatus s = await Permission.storage.request();

    print(s);

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
    // print('rootDir path');
    // print(rootDir+ROOT_DIRECTORY_ANDROID);
    isWhatsApp = Directory(rootDir + ROOT_DIRECTORY_ANDROID).existsSync();
    isWhatsAppBusiness =
        Directory(rootDir + ROOT_DIRECTORY_ANDROID_WHATSAPP_BUSINESS)
            .existsSync();
    print("Whatsapp bool is $isWhatsApp");
    print("Whatsapp Business bool is $isWhatsAppBusiness");
    var statusesPath = '';
    if (isWhatsApp == true && isWhatsAppBusiness == false) {
      statusesPath = rootDir +
          (Platform.isIOS ? ROOT_DIRECTORY_IOS : ROOT_DIRECTORY_ANDROID);
    } else if (isWhatsAppBusiness == true && isWhatsApp == false) {
      statusesPath = rootDir +
          (Platform.isIOS
              ? ROOT_DIRECTORY_IOS
              : ROOT_DIRECTORY_ANDROID_WHATSAPP_BUSINESS);
    } else {
      statusesPath = rootDir +
          (Platform.isIOS ? ROOT_DIRECTORY_IOS : ROOT_DIRECTORY_ANDROID);
    }
    print("statusesPath path");
    print(statusesPath);
    final dir = Directory(statusesPath);
    List<FileSystemEntity> files = dir.listSync();
    // print('files');
    // print(files);
    // print("file length:${files.length}");
    List<FileSystemEntity> files2 = [];
    for (File f in files) {
      // print(f.path);
      if (f.path.endsWith(".jpg") || f.path.endsWith(".mp4")) {
        files2.add(File(f.path));
      }
    }

    return files2;
  }

  Future<String> getRootDir() async {
    var externalDirectoryPath = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();
    if (externalDirectoryPath != null) {
      final subbed = externalDirectoryPath.path.replaceFirst(
        ANDROID_DATA_FREAKTEMPLATE_STATUSSAVER_FILES,
        '',
      );
      return subbed;
    }
    throw FAILED_TO_GET_EXTERNAL_STORAGE_DIRECTORY;
  }

  createAndSaveFile(fPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      downloadLocationPath = prefs.getString(cnst.Session.downloadPath);
    });
    final path = Platform.isIOS
        ? await getDownloadsDirectory()
        : await getExternalStorageDirectory();
    print("path.path");
    // print(path.path);
    print(downloadLocationPath + "/");
    File f =
        File(downloadLocationPath.toString() + "/" + fPath.split("/").last);
    await f.create();
    f.writeAsBytes(File(fPath).readAsBytesSync());
    Fluttertoast.showToast(
        msg: STATUS_SAVED_SUCCESSFULLY,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: cnst.appPrimaryMaterialColor,
        textColor: Colors.white,
        fontSize: 16.0);
    print("FILE SAVED SUCCESSFULLY : " + f.path);
  }

  getSwitch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deleteSwitch = prefs.getBool(cnst.Session.deleteSwitch.toString());
    });
  }
}
