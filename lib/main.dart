// Reference page: https://github.com/parse-community/Parse-SDK-Flutter

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ShowImdbImages.dart';
import 'widgets/TabBarApp.dart';
import 'notifications.dart';

void main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  // var channels = await getChannels();
  // print(channels);
  if (!kIsWeb) {
    deleteOldNotifications();
    initializeNotifications();
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ShowImdbImages()),
    ],
    child: MaterialApp(
      title: 'Navigation Basics',
      home: TabBarApp(),
    ),
  ));
}
