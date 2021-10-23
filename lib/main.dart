import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver/Testing/Dashboard.dart';
import 'package:whatsapp_status_saver/Common/Constants.dart' as cnst;
import 'package:whatsapp_status_saver/admob_service.dart';

import 'Testing/FeedbackScreen.dart';

String ROOT_DIRECTORY_ANDROID = '/WhatsApp/Media/.Statuses';
String ROOT_DIRECTORY_ANDROID_WHATSAPP_BUSINESS =
    '/WhatsApp Business/Media/.Statuses';
String ROOT_DIRECTORY_IOS = '';

String banner_Ad_Id='ca-app-pub-3940256099942544/6300978111';
String interstitial_Ad_Id='ca-app-pub-3940256099942544/1033173712';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AdMobService.initialize();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: Dashboard(),
      initialRoute: '/',
      routes: {
        '/': (context) => Dashboard(),
        '/FeedbackScreen': (context) => FeedbackScreen(),
      },
      theme: ThemeData(
        fontFamily: 'Andale Mono',
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(
            color: cnst.appPrimaryMaterialColor,
          ),
        ),
      ),
    ),
  );
}
